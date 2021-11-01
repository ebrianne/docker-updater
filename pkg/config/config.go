package config

// Config
type Config struct {
	ServerPort string `config:"server_port"`
}

func getDefaultConfig() *Config {
	return &Config{
		ServerPort: "9000",
	}
}

func Load() *Config {
	cfg := getDefaultConfig()
	return cfg
}
