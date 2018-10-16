package main

import (
   "fmt"
   "github.com/labstack/echo"
   "github.com/labstack/echo/middleware"
   "github.com/sirupsen/logrus"
   "net/http"
)
var log =logrus.New()

func init() {
   log.Formatter = new(logrus.JSONFormatter)
   log.Formatter = new(logrus.TextFormatter) // default
   log.Level = logrus.DebugLevel
}

func main() {
   fmt.Println("Main function :")
   e := echo.New()
   e.Use(middleware.Logger())
   e.Use(middleware.Recover())
   // Routes
   e.GET("/go-docker",  goWithDocker)
   e.Logger.Fatal(e.Start(":8080"))
}

func goWithDocker(c echo.Context)error{
 return c.JSON(http.StatusOK, "Go with Docker Container v2")
}
