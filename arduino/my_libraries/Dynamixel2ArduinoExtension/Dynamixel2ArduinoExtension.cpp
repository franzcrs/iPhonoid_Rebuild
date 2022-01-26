#include "Arduino.h"
#include "Dynamixel2ArduinoExtension.h"

namespace DYNAMIXEL{

const uint16_t model_number_table[] PROGMEM = {
    AX12A, AX12W, AX18A,
    
    RX10, RX24F, RX28, RX64,
    
    DX113, DX116, DX117,
    
    EX106,

    MX12W,  MX28,   MX64,    MX106,
    MX28_2, MX64_2, MX106_2,
    
    XL320,
    XL330_M288,
    XL330_M077,
    XC330_M181,
    XC330_M288,    
    XC330_T181,
    XC330_T288,    
    XL430_W250,
    XXL430_W250,
    XC430_W150,  XC430_W240,
    XXC430_W250,
    XM430_W210,  XM430_W350,
    XM540_W150,  XM540_W270, 
    XH430_V210,  XH430_V350, XH430_W210, XH430_W350,
    XH540_V150,  XH540_V270, XH540_W150, XH540_W270,
    XD430_T210,  XD430_T350,
    XD540_T150,  XD540_T270,
    XW430_T200,  XW430_T333,
    XW540_T140,  XW540_T260,

    PRO_L42_10_S300_R,   
    PRO_L54_30_S400_R,   PRO_L54_30_S500_R,   PRO_L54_50_S290_R,   PRO_L54_50_S500_R,
    PRO_M42_10_S260_R,   PRO_M42_10_S260_RA,
    PRO_M54_40_S250_R,   PRO_M54_40_S250_RA,  PRO_M54_60_S250_R,   PRO_M54_60_S250_RA,
    PRO_H42_20_S300_R,   PRO_H42_20_S300_RA,
    PRO_H54_100_S500_R,  PRO_H54_100_S500_RA, PRO_H54_200_S500_R,  PRO_H54_200_S500_RA,

    PRO_M42P_010_S260_R, 
    PRO_M54P_040_S250_R, PRO_M54P_060_S250_R,
    PRO_H42P_020_S300_R, 
    PRO_H54P_100_S500_R, PRO_H54P_200_S500_R
};

const uint8_t model_number_table_count = sizeof(model_number_table)/sizeof(model_number_table[0]);

enum Functions{
  SET_ID,
  SET_BAUD_RATE,

  SET_PROTOCOL,
 
  SET_POSITION,
  GET_POSITION,

  SET_VELOCITY,
  GET_VELOCITY,

  SET_PWM,
  GET_PWM,

  SET_CURRENT,
  GET_CURRENT,

  LAST_DUMMY_FUNC = 0xFF
};

} //namespace DYNAMIXEL

using namespace DYNAMIXEL;

Dynamixel2ArduinoExtension::Dynamixel2ArduinoExtension(HardwareSerial& port, int dir_pin) : Dynamixel2Arduino(port, dir_pin){}

bool Dynamixel2ArduinoExtension::regwriteControlTableItem(uint8_t item_idx, uint8_t id, int32_t data, uint32_t timeout){
  bool ret = false;
  uint16_t model_num = Dynamixel2ArduinoExtension::getModelNumberFromTable(id);
  
  // To use the command function without ping() or model addition.
  if(model_num == UNREGISTERED_MODEL){
    if(setModelNumber(id, getModelNumber(id)) == true){
      model_num = getModelNumberFromTable(id);
    }
  }

  if(model_num != UNREGISTERED_MODEL){
    ret = regwriteControlTableItem(model_num, item_idx, id, data, timeout);
  }else{
    setLastLibErrCode(D2A_LIB_ERROR_UNKNOWN_MODEL_NUMBER);
  }

  return ret;
}

uint16_t Dynamixel2ArduinoExtension::getModelNumberFromTable(uint8_t id){
  uint8_t idx;
  uint16_t model_num;

  if(id > 254){
    setLastLibErrCode(DXL_LIB_ERROR_INVAILD_ID);
    return UNREGISTERED_MODEL;
  }

  idx = model_number_idx_[id];
  model_num = (idx < model_number_table_count) ? pgm_read_word(&model_number_table[idx]) : UNREGISTERED_MODEL;

  return model_num;
}

bool Dynamixel2ArduinoExtension::regwriteControlTableItem(uint16_t model_num, uint8_t item_idx, uint8_t id, int32_t data, uint32_t timeout)
{
  bool ret = false;
  ControlTableItemInfo_t item_info;
  
  p_dxl_port_ = (SerialPortHandler*)getPort();
  if(p_dxl_port_ == nullptr){
    setLastLibErrCode(D2A_LIB_ERROR_NULLPTR_PORT_HANDLER);
    return false;
  }

  item_info = getControlTableItemInfo(model_num, item_idx);
  if(item_info.addr_length > 0){
    ret = regWrite(id, item_info.addr, (uint8_t*)&data, item_info.addr_length, timeout);
  }

  return ret;
}