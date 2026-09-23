import React, { useState } from "react";
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Alert } from "react-native";
import { register } from "../api/api";

export default function RegisterScreen({ navigation }: any) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");

  const handleRegister = async () => {
    if (!email || !password) {
      Alert.alert("Ошибка", "Заполни все поля");
      return;
    }
    if (password !== confirm) {
      Alert.alert("Ошибка", "Пароли не совпадают");
      return;
    }
    try {
      await register(email, password);
      Alert.alert("Успех", "Аккаунт создан!");
      navigation.replace("Login");
    } catch (e: any) {
      Alert.alert("Ошибка", e.response?.data?.detail || "Не удалось зарегистрироваться");
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Регистрация</Text>

      <TextInput
        style={styles.input}
        placeholder="Почта"
        placeholderTextColor="#708499"
        keyboardType="email-address"
        autoCapitalize="none"
        value={email}
        onChangeText={setEmail}
      />
      <TextInput
        style={styles.input}
        placeholder="Пароль"
        placeholderTextColor="#708499"
        secureTextEntry
        value={password}
        onChangeText={setPassword}
      />
      <TextInput
        style={styles.input}
        placeholder="Повтори пароль"
        placeholderTextColor="#708499"
        secureTextEntry
        value={confirm}
        onChangeText={setConfirm}
      />

      <TouchableOpacity style={styles.button} onPress={handleRegister}>
        <Text style={styles.buttonText}>Создать</Text>
      </TouchableOpacity>

      <TouchableOpacity onPress={() => navigation.goBack()}>
        <Text style={styles.link}>Назад</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#17212B", justifyContent: "center", padding: 30 },
  title: { fontSize: 32, fontWeight: "bold", color: "#2AABEE", textAlign: "center", marginBottom: 40 },
  input: { backgroundColor: "#0E1621", color: "#FFF", padding: 16, borderRadius: 12, marginBottom: 15, fontSize: 16 },
  button: { backgroundColor: "#2AABEE", padding: 16, borderRadius: 12, alignItems: "center", marginTop: 10 },
  buttonText: { color: "#FFF", fontSize: 18, fontWeight: "bold" },
  link: { color: "#2AABEE", textAlign: "center", marginTop: 25, fontSize: 16 },
});

