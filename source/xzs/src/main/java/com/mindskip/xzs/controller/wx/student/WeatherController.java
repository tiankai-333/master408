package com.mindskip.xzs.controller.wx.student;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mindskip.xzs.base.RestResponse;
import com.mindskip.xzs.controller.wx.BaseWXApiController;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

@Controller("WXStudentWeatherController")
@RequestMapping(value = "/api/wx/student/weather")
@ResponseBody
public class WeatherController extends BaseWXApiController {

    private static final Logger logger = LoggerFactory.getLogger(WeatherController.class);
    private final ObjectMapper objectMapper = new ObjectMapper();

    private static final Map<String, double[]> CITY_COORDS = new LinkedHashMap<>();
    static {
        CITY_COORDS.put("松江区", new double[]{31.03, 121.22});
        CITY_COORDS.put("浦东新区", new double[]{31.22, 121.54});
        CITY_COORDS.put("黄浦区", new double[]{31.23, 121.47});
        CITY_COORDS.put("徐汇区", new double[]{31.19, 121.44});
        CITY_COORDS.put("长宁区", new double[]{31.22, 121.42});
        CITY_COORDS.put("静安区", new double[]{31.23, 121.45});
        CITY_COORDS.put("普陀区", new double[]{31.25, 121.40});
        CITY_COORDS.put("虹口区", new double[]{31.26, 121.51});
        CITY_COORDS.put("杨浦区", new double[]{31.27, 121.53});
        CITY_COORDS.put("闵行区", new double[]{31.11, 121.38});
        CITY_COORDS.put("宝山区", new double[]{31.40, 121.49});
        CITY_COORDS.put("嘉定区", new double[]{31.39, 121.27});
        CITY_COORDS.put("金山区", new double[]{30.74, 121.34});
        CITY_COORDS.put("青浦区", new double[]{31.15, 121.12});
        CITY_COORDS.put("奉贤区", new double[]{30.92, 121.47});
        CITY_COORDS.put("崇明区", new double[]{31.63, 121.40});
        CITY_COORDS.put("北京市", new double[]{39.90, 116.40});
        CITY_COORDS.put("广州市", new double[]{23.13, 113.26});
        CITY_COORDS.put("深圳市", new double[]{22.54, 114.06});
        CITY_COORDS.put("杭州市", new double[]{30.27, 120.15});
        CITY_COORDS.put("南京市", new double[]{32.06, 118.80});
        CITY_COORDS.put("成都市", new double[]{30.57, 104.07});
        CITY_COORDS.put("武汉市", new double[]{30.59, 114.30});
        CITY_COORDS.put("西安市", new double[]{34.26, 108.94});
        CITY_COORDS.put("重庆市", new double[]{29.56, 106.55});
        CITY_COORDS.put("苏州市", new double[]{31.30, 120.62});
        CITY_COORDS.put("天津市", new double[]{39.13, 117.20});
        CITY_COORDS.put("长沙市", new double[]{28.23, 112.94});
        CITY_COORDS.put("合肥市", new double[]{31.82, 117.23});
    }

    @RequestMapping(value = "/current", method = RequestMethod.POST)
    public RestResponse<Map<String, Object>> current(@RequestParam(required = false, defaultValue = "松江区") String city) {
        try {
            double[] coords = CITY_COORDS.get(city);
            String cityName = city;

            if (coords == null) {
                coords = geocode(city);
                if (coords == null) {
                    return RestResponse.fail(500, "未找到城市: " + city);
                }
            }

            String weatherUrl = "https://api.open-meteo.com/v1/forecast?latitude=" + coords[0]
                    + "&longitude=" + coords[1]
                    + "&current=temperature_2m,weather_code";

            String weatherJson = httpGet(weatherUrl);
            JsonNode root = objectMapper.readTree(weatherJson);
            JsonNode current = root.get("current");

            double temp = current.get("temperature_2m").asDouble();
            int code = current.get("weather_code").asInt();

            Map<String, Object> result = new HashMap<>();
            result.put("city", cityName);
            result.put("temperature", Math.round(temp));
            result.put("weatherCode", code);
            result.put("icon", codeToIcon(code));
            result.put("description", codeToDesc(code));
            return RestResponse.ok(result);
        } catch (Exception e) {
            logger.error("[weather] query failed for city={}: {}", city, e.getMessage());
            return RestResponse.fail(500, "天气查询失败");
        }
    }

    private double[] geocode(String city) {
        try {
            String url = "https://geocoding-api.open-meteo.com/v1/search?name="
                    + URLEncoder.encode(city, "UTF-8") + "&count=1&language=zh";
            String json = httpGet(url);
            JsonNode root = objectMapper.readTree(json);
            if (root.has("results") && root.get("results").size() > 0) {
                JsonNode first = root.get("results").get(0);
                return new double[]{
                        first.get("latitude").asDouble(),
                        first.get("longitude").asDouble()
                };
            }
        } catch (Exception e) {
            logger.warn("[weather] geocode failed for city={}: {}", city, e.getMessage());
        }
        return null;
    }

    private String httpGet(String urlStr) throws Exception {
        URL url = new URL(urlStr);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(5000);
        conn.setReadTimeout(5000);
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(conn.getInputStream(), "UTF-8"))) {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            return sb.toString();
        } finally {
            conn.disconnect();
        }
    }

    private String codeToIcon(int code) {
        if (code == 0) return "☀️";
        if (code <= 3) return "⛅";
        if (code <= 48) return "🌫️";
        if (code <= 57) return "🌦️";
        if (code <= 67) return "🌧️";
        if (code <= 77) return "❄️";
        if (code <= 82) return "🌧️";
        if (code <= 86) return "🌨️";
        if (code <= 99) return "⛈️";
        return "🌤️";
    }

    private String codeToDesc(int code) {
        if (code == 0) return "晴";
        if (code <= 3) return "多云";
        if (code <= 48) return "雾";
        if (code <= 57) return "小雨";
        if (code <= 67) return "雨";
        if (code <= 77) return "雪";
        if (code <= 82) return "阵雨";
        if (code <= 86) return "阵雪";
        if (code <= 99) return "雷暴";
        return "多云";
    }
}
