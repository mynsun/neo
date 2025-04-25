const express = require("express");
const router = express.Router();
const axios = require("axios");

const FASTAPI_URL = "http://localhost:8000";

router.get("/by_address", async (req, res) => {
    const { address, radius } = req.query;
    try {
        const response = await axios.get(`${FASTAPI_URL}/r_by_address`, {
        params: { address, radius: radius || 2000 }
        });
        res.json(response.data);
    } catch (err) {
        console.error("주소 기반 충전소 검색 오류:", err.message);
        res.status(err.response?.status || 500).json({ error: err.message });
    }
    });

    router.get("/nearby", async (req, res) => {
    const { latitude, longitude, radius } = req.query;
    try {
        const response = await axios.get(`${FASTAPI_URL}/r_nearby`, {
        params: { latitude, longitude, radius: radius || 2000 }
        });
        res.json(response.data);
    } catch (err) {
        console.error("위치 기반 충전소 검색 오류:", err.message);
        res.status(err.response?.status || 500).json({ error: err.message });
    }
    });

    router.get("/detail", async (req, res) => {
    const { latitude, longitude } = req.query;
    try {
        const response = await axios.get(`${FASTAPI_URL}/r_detail`, {
        params: { latitude, longitude }
        });
        res.json(response.data);
    } catch (err) {
        console.error("충전소 상세 조회 오류:", err.message);
        res.status(err.response?.status || 500).json({ error: err.message });
    }
    });

    router.get("/route", async (req, res) => {
        const { start_address, end_address, range } = req.query;
        try {
            const response = await axios.get(`${FASTAPI_URL}/r_route`, {
                params: {
                    start_address,
                    end_address,
                    range
                }
            });
            res.json(response.data);
        } catch (err) {
            console.error("경로 기반 충전소 검색 오류:", err.message);
            res.status(err.response?.status || 500).json({ error: err.message });
        }
    });

    module.exports = router;