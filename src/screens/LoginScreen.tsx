import React, { useState } from "react";
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Alert } from "react-native";
import { login } from "../api/api";
export default function LoginScreen({ navigation }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const handleLogin = async () => {
    if (!email || !password) { Alert.alert("Ошибка", "Заполни все поля"); return; }
    try { await login(email, password); navigation.replace("Chats"); }
    catch (e) { Alert.alert("Ошибка", "Не удалось войти"); }
  };
  return (
    <View style={styles.container}>
      <Text style={styles.logo}>NEXUSCHAT</Text>
      <Text style={styles.subtitle}>Мессенджер нового поколения</Text>
      <TextInput style={styles.input} placeholder="Почта" placeholderTextColor="#708499" keyboardType="email-address" autoCapitalize="none" value={email} onChangeText={setEmail} />
      <TextInput style={styles.input} placeholder="Пароль" placeholderTextColor="#708499" secureTextEntry value={password} onChangeText={setPassword} />
      <TouchableOpacity style={styles.button} onPress={handleLogin}><Text style={styles.buttonText}>Войти</Text></TouchableOpacity>
      <TouchableOpacity onPress={() => navigation.navigate("Register")}><Text style={styles.link}>Создать аккаунт</Text></TouchableOpacity>
    </View>
  );
}
const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#17212B", justifyContent: "center", padding: 30 },
  logo: { fontSize: 48, fontWeight: "bold", color: "#2AABEE", textAlign: "center", letterSpacing: 2 },
  subtitle: { fontSize: 14, color: "#708499", textAlign: "center", marginBottom: 50 },
  input: { backgroundColor: "#0E1621", color: "#FFF", padding: 16, borderRadius: 12, marginBottom: 15, fontSize: 16 },
  button: { backgroundColor: "#2AABEE", padding: 16, borderRadius: 12, alignItems: "center", marginTop: 10 },
  buttonText: { color: "#FFF", fontSize: 18, fontWeight: "bold" },
  link: { color: "#2AABEE", textAlign: "center", marginTop: 25, fontSize: 16 },
});
