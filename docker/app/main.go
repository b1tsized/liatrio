package main

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()
	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message":   "Automate all the things!",
			"timestamp": time.Now().Unix(),
		})
	})
	r.GET("/healthcheck", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"success": true,
			"message": "It is working",
		})
	})
	r.NoRoute(func(c *gin.Context) {
		c.JSON(404, gin.H{
			"success": false,
			"message": "This page is not found. Please try a different URL.",
		})
	})
	err := r.Run(":5000")
	if err != nil {
		return
	}
}
