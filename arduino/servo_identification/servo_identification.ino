/**
 * @file servo_identification.ino
 * @author Franz Chuquirachi (@franzcrs)
 * @brief Performs an identification of servos connected to Dynamixel Shield of the half-built iPhonoid
 * @version 0.1
 * @date 2021-12-06
 * 
 * @copyright Copyright (c) 2021
 * 
 */

#include <DynamixelShield.h>
#include <stdarg.h>

/**
 * DYNAMIXELShield uses digital pins (0,1) to communicate with the servos.
 * These are the same pins as in Arduino Uno/Mega, used for the usb communication.
 * Therefore, the interface 'Serial' (pins (0,1)) cannot be used with normality.
 * And another serial interface needs to be created.
 * For other boards, pins (0,1) are not connected to the usb connector.
 * For detailed information refer to:
 * https://www.arduino.cc/reference/en/language/functions/communication/serial/
 * https://emanual.robotis.com/docs/en/parts/interface/dynamixel_shield/
 * */
#if defined(ARDUINO_AVR_UNO) || defined(ARDUINO_AVR_MEGA2560)
	#include <SoftwareSerial.h>
	SoftwareSerial soft_serial(7, 8); // New Arduino/DYNAMIXELShield UART pins
	#define DEBUG_SERIAL soft_serial
#elif defined(ARDUINO_SAM_DUE) || defined(ARDUINO_SAM_ZERO)
	#define DEBUG_SERIAL SerialUSB
#else
	#define DEBUG_SERIAL Serial
#endif

const float DXL_PROTOCOL_VERSION = 1.0; // Servos AX-12A use protocol 1.0
// Refer to Compatibility Table in: https://emanual.robotis.com/docs/en/dxl/protocol1/

DynamixelShield dxl;							// Declaring an instance of DynamixelShield
using namespace ControlTableItem; // Required namespace to use Controltable item names

/**
 * @brief Function for formatted printing in Arduino, same as printf of C language. Prints to DEBUG_SERIAL.
 * 
 * @param input Formatted string and then the variable names followed by comma
 */
void Serialprintln(const char *input...)
{
	va_list args;
	va_start(args, input);
	for (const char *i = input; *i != 0; ++i)
	{
		if (*i != '%')
		{
			DEBUG_SERIAL.print(*i);
			continue;
		}
		switch (*(++i))
		{
		case '%':
			DEBUG_SERIAL.print('%');
			break;
		case 's':
			DEBUG_SERIAL.print(va_arg(args, char *));
			break;
		case 'd':
			DEBUG_SERIAL.print(va_arg(args, int), DEC);
			break;
		case 'b':
			DEBUG_SERIAL.print(va_arg(args, int), BIN);
			break;
		case 'o':
			DEBUG_SERIAL.print(va_arg(args, int), OCT);
			break;
		case 'x':
			DEBUG_SERIAL.print(va_arg(args, int), HEX);
			break;
		case 'f':
			DEBUG_SERIAL.print(va_arg(args, double), 2);
			break;
		}
	}
	DEBUG_SERIAL.println();
	va_end(args);
}

/**
 * @brief Displays verification of existance of servo in the DEBUG_SERIAL interface
 * 
 * @param id id number of servo to verify
 */
void verifyservo(byte id)
{
	if (dxl.ping(id) == true)
	{
		Serialprintln("The servo with ID = %d exists, its model is: %d", id, dxl.getModelNumber(id));
		// TODO: Make a simple movement after acknowledge
	}
	else
	{
		Serialprintln("The servo with ID = %d doesn't exist", id);
	}
}

void setup()
{
	DEBUG_SERIAL.begin(115200); // Initialize the Arduino - Computer communication interface
	dxl.begin(1000000);					// Initialize Dynamixel communication interface, begin() method receives baudrate as input
	// Default baud rate of Servo AX-12A is 1 000 000 bps, refer to: https://emanual.robotis.com/docs/en/dxl/ax/ax-12a/#baud-rate
	dxl.setPortProtocolVersion(DXL_PROTOCOL_VERSION); //Configuring the protocol version of instance
}

void loop()
{
	static byte DXL_ID = 1;
	verifyservo(DXL_ID);
	DXL_ID++;
	if (DXL_ID > 9){
		DXL_ID = 1;
	}
	delay(1000);
}