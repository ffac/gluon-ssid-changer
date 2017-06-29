if need_table('ssid_changer', nil, false) then
  need_boolean('ssid_changer.enabled', false)
  need_number('ssid_changer.switch_timeframe', false)
  need_number('ssid_changer.first', false)
  need_string('ssid_changer.prefix', false)
  need_string('ssid_changer.suffix', false)
  if need_boolean('ssid_changer.tq_limit_enabled', false) then
    need_number('ssid_changer.tq_limit_max', false)
    need_number('ssid_changer.tq_limit_min', false)
  end
end
