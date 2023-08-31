#include "msp.h"

/**
 * main.c
 */

#define CLOCK_FREQ              32768
#define ADC_MAX_VALUE           16383
#define count_to_milli(milli)   ((CLOCK_FREQ * milli) / 1000)

#define VALUE_MIN 0.9775f
#define VALUE_MAX 1.924f

void setupClock(void);
void setupTimerA0(void);
void setupTimerA1(void);
void setupADC(void);
void setupTimerPins(void);
void setupADCPins(void);

void main(void)
{
    WDT_A->CTL = WDT_A_CTL_PW | WDT_A_CTL_HOLD; // stop watchdog timer

    setupClock();

    setupTimerA0();

    setupTimerA1();

    setupADC();

    setupTimerPins();

    setupADCPins();

    while(1){
        __NOP;
    }
}

void setupClock(void) {
    // for LFXTCLK
    CS->KEY = CS_KEY_VAL;
    // setup the SMCLK
    CS->CTL1 = CS_CTL1_SELS_0;
    CS->CLKEN = CS_CLKEN_SMCLK_EN;
}

void setupTimerA0(void) {
    // setup the timer A0
    TIMER_A0->CTL |= TIMER_A_CTL_SSEL__SMCLK;
    TIMER_A0->CTL |= TIMER_A_CTL_MC_1;

    // set the value for CCR0
    TIMER_A0->CCR[0] = count_to_milli(20);
    // set the value for CCR1
    TIMER_A0->CCR[1] = count_to_milli(1);

    // set the mode for the CCR (capture mode)
    TIMER_A0->CCTL[0] = TIMER_A_CCTLN_CM_1;
    TIMER_A0->CCTL[1] = TIMER_A_CCTLN_CM_1;

    // set the outmode for the timer
    //TIMER_A0->CCTL[0] |= TIMER_A_CCTLN_OUTMOD_6;
    TIMER_A0->CCTL[1] |= TIMER_A_CCTLN_OUTMOD_6;

    // enable interrupt for timer
    //NVIC_EnableIRQ(TA0_0_IRQn);
    //NVIC_SetPriority(TA0_0_IRQn, 2);
    TIMER_A0->CCTL[0] = TIMER_A_CCTLN_CCIE;
}

void setupTimerA1(void) {
    // setup the timer A0
    TIMER_A1->CTL |= TIMER_A_CTL_SSEL__SMCLK;
    TIMER_A1->CTL |= TIMER_A_CTL_MC_1;

    // set the value for CCR0
    TIMER_A1->CCR[0] = count_to_milli(50);

    // enable interrupt for timer
    NVIC_EnableIRQ(TA1_0_IRQn);
    NVIC_SetPriority(TA1_0_IRQn, 2);
    TIMER_A1->CCTL[0] = TIMER_A_CCTLN_CCIE;
}

void setupADC(void) {
    ADC14->CTL0 |= ADC14_CTL0_ON;

    // setup control
    ADC14->CTL0 |= ADC14_CTL0_SHP;
    ADC14->CTL0 |= ADC14_CTL0_SSEL_4;
    ADC14->CTL0 |= ADC14_CTL0_CONSEQ_0;

    // setup memory control
    ADC14->MCTL[0] = ADC14_MCTLN_INCH_13;

    //enable interrupt on ADC
    NVIC_EnableIRQ(ADC14_IRQn);
    NVIC_SetPriority(ADC14_IRQn, 3);
    ADC14->IER0 = ADC14_IER0_IE0;

    ADC14->CTL0 |= ADC14_CTL0_ENC;
}

void setupTimerPins(void) {
    // setup the output pins
    P2->DIR = 0x11;

    P2->SEL0 = 0x10;
    P2->SEL1 = 0x00;

    P2->OUT = 0x01;
}

void setupADCPins(void) {
    // setup the input pins
    P4->DIR = 0x00;

    P4->SEL0 = 0x01;
    P4->SEL1 = 0x01;

    P4->OUT = 0x00;
}

void TA1_0_IRQHandler(void) {
    TIMER_A1->CCTL[0] &= ~0x0001;
    P2->OUT ^= 0x01;
    ADC14->CTL0 |= ADC14_CTL0_SC;
}

void ADC14_IRQHandler(void) {
    ADC14->IER1 = 0x0000;

    // set the period for the cervo from 1 to 2ms
    // ADC min value is 0x0000
    // ADC max value is 0x2FFF (=16383)

    int result = ADC14->MEM[0];
    //float value = 37 * ((float)(result / 16383) + 1);
    int value = (int)((count_to_milli(1) * result) / ADC_MAX_VALUE) + count_to_milli(1);
    // rescale to be between 1 and 2 ms
    float time = VALUE_MIN + (value / (VALUE_MAX - VALUE_MIN));


    TIMER_A0->CCR[1] = (int)time;

}



