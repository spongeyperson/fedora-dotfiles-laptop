var TemperatureUnit = {
    CELSIUS: 0,
    FAHRENHEIT: 1,
    KELVIN: 2
}

function toFahrenheit(celsia) {
    return celsia * (9/5) + 32
}

function toKelvin(celsia) {
    return celsia + 273.15
}

function getTemperatureStr(celsiaDouble, temperatureUnit) {
    //Disable Print to Kernel Log (Fix)
    //https://github.com/kotelnik/plasma-applet-thermal-monitor/issues/41#issuecomment-609458864
    //print('temp unit: ' + temperatureUnit)
    return getTemperature(celsiaDouble, temperatureUnit) + (temperatureUnit === TemperatureUnit.CELSIUS || temperatureUnit === TemperatureUnit.FAHRENHEIT ? '°' : '')
}

function getTemperature(celsiaDouble, temperatureUnit) {
    var fl = celsiaDouble
    if (temperatureUnit === TemperatureUnit.FAHRENHEIT) {
        fl = toFahrenheit(fl)
    } else if (temperatureUnit === TemperatureUnit.KELVIN) {
        fl = toKelvin(fl)
    }
    return Math.round(fl)
}
