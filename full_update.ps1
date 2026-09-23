# full_update.ps1
# Полное обновление NEXUSCHAT

$BASE = "E:\SkaryChatApp"
$SCREENS = "$BASE\src\screens"
$COMPONENTS = "$BASE\src\components"
$API = "$BASE\src\api"
$THEME = "$BASE\src\theme"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NEXUSCHAT — ПОЛНОЕ ОБНОВЛЕНИЕ" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

# Создаём папки
New-Item -ItemType Directory -Force -Path $SCREENS | Out-Null
New-Item -ItemType Directory -Force -Path $COMPONENTS | Out-Null
New-Item -ItemType Directory -Force -Path $API | Out-Null
New-Item -ItemType Directory -Force -Path $THEME | Out-Null

# ============ THEME ============
$themeFile = @'
export const colors = {
  primary: "#2AABEE",
  primaryDark: "#229ED9",
  dark: {
    background: "#17212B",
    surface: "#0E1621",
    card: "#1C2733",
    text: "#FFFFFF",
    textSecondary: "#708499",
    border: "#101921",
    messageOut: "#2B5278",
    messageIn: "#182533",
    accent: "#2AABEE",
  },
  light: {
    background: "#FFFFFF",
    surface: "#F5F5F5",
    card: "#FFFFFF",
    text: "#000000",
    textSecondary: "#8E8E93",
    border: "#E5E5E5",
    messageOut: "#EFFDFF",
    messageIn: "#FFFFFF",
    accent: "#2AABEE",
  },
};

export const fonts = {
  sizes: {
    small: 12,
    medium: 14,
    large: 16,
    title: 20,
    header: 24,
  },
};
'@
Set-Content -Path "$THEME\colors.ts" -Value $themeFile -Encoding UTF8
Write-Host "[+] colors.ts" -ForegroundColor Green

# ============ API CLIENT ============
$apiClient = @'
import axios from "axios";
import AsyncStorage from "@react-native-async-storage/async-storage";

const API_URL = "https://skarychat.onrender.com";

const api = axios.create({
  baseURL: API_URL,
  timeout: 10000,
});

api.interceptors.request.use(async (config) => {
  const token = await AsyncStorage.getItem("token");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// ===== АВТОРИЗАЦИЯ =====
export const register = async (email: string, password: string) => {
  const res = await api.post("/api/register", { email, password });
  return res.data;
};

export const login = async (email: string, password: string) => {
  const res = await api.post("/api/login", { email, password });
  await AsyncStorage.setItem("token", res.data.access_token);
  return res.data;
};

export const getMe = async () => {
  const res = await api.get("/api/me");
  return res.data;
};

export const logout = async () => {
  await AsyncStorage.removeItem("token");
};

// ===== ПРОФИЛЬ =====
export const updateProfile = async (data: { username?: string; bio?: string }) => {
  const res = await api.post("/api/profile", data);
  return res.data;
};

export const updateTheme = async (theme: string) => {
  const res = await api.post("/api/theme", { theme });
  return res.data;
};

export const updatePrivacy = async (settings: any) => {
  const res = await api.post("/api/privacy", settings);
  return res.data;
};

export const getPrivacy = async () => {
  const res = await api.get("/api/privacy");
  return res.data;
};

// ===== ЧАТЫ =====
export const getChats = async () => {
  const res = await api.get("/api/chats");
  return res.data;
};

export const createChat = async (name: string, members: number[] = [], isChannel: boolean = false) => {
  const res = await api.post("/api/chats", { name, members, is_channel: isChannel });
  return res.data;
};

export const getChatInfo = async (chatId: number) => {
  const res = await api.get(`/api/chats/${chatId}`);
  return res.data;
};

export const getPublicChats = async () => {
  const res = await api.get("/api/public-chats");
  return res.data;
};

// ===== СООБЩЕНИЯ =====
export const getMessages = async (chatId: number) => {
  const res = await api.get(`/api/messages/${chatId}`);
  return res.data;
};

export const sendMessage = async (chatId: number, text: string, replyTo?: number) => {
  const res = await api.post("/api/messages", { chat_id: chatId, text, reply_to: replyTo });
  return res.data;
};

export const editMessage = async (messageId: number, text: string) => {
  const res = await api.post(`/api/messages/${messageId}/edit`, { text });
  return res.data;
};

export const deleteMessage = async (messageId: number) => {
  const res = await api.post(`/api/messages/${messageId}/delete`);
  return res.data;
};

export const addReaction = async (messageId: number, emoji: string) => {
  const res = await api.post(`/api/messages/${messageId}/reaction`, { emoji });
  return res.data;
};

export const searchMessages = async (chatId: number, query: string) => {
  const res = await api.get(`/api/messages/${chatId}/search?q=${query}`);
  return res.data;
};

// ===== ПОЛЬЗОВАТЕЛИ =====
export const getUsers = async () => {
  const res = await api.get("/api/users");
  return res.data;
};

export const searchUsers = async (query: string) => {
  const res = await api.get(`/api/users/search?q=${query}`);
  return res.data;
};

export default api;
'@
Set-Content -Path "$API\api.ts" -Value $apiClient -Encoding UTF8
Write-Host "[+] api.ts" -ForegroundColor Green

# ============ LOGIN SCREEN ============
$loginScreen = @'
import React, { useState } from "react";
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Alert } from "react-native";
import { login } from "../api/api";
import { colors } from "../theme/colors";

export default function LoginScreen({ navigation }: any) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const handleLogin = async () => {
    if (!email || !password) {
      Alert.alert("Ошибка", "Заполни все поля");
      return;
    }
    try {
      await login(email, password);
      navigation.replace("Chats");
    } catch (e: any) {
      Alert.alert("Ошибка", e.response?.data?.detail || "Не удалось войти");
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.logo}>NEXUSCHAT</Text>
      <Text style={styles.subtitle}>Мессенджер нового поколения</Text>

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

      <TouchableOpacity style={styles.button} onPress={handleLogin}>
        <Text style={styles.buttonText}>Войти</Text>
      </TouchableOpacity>

      <TouchableOpacity onPress={() => navigation.navigate("Register")}>
        <Text style={styles.link}>Создать аккаунт</Text>
      </TouchableOpacity>
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
'@
Set-Content -Path "$SCREENS\LoginScreen.tsx" -Value $loginScreen -Encoding UTF8
Write-Host "[+] LoginScreen.tsx" -ForegroundColor Green

# ============ REGISTER SCREEN ============
$registerScreen = @'
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
'@
Set-Content -Path "$SCREENS\RegisterScreen.tsx" -Value $registerScreen -Encoding UTF8
Write-Host "[+] RegisterScreen.tsx" -ForegroundColor Green

# ============ CHAT LIST ITEM ============
$chatItem = @'
import React from "react";
import { View, Text, TouchableOpacity, StyleSheet } from "react-native";

export default function ChatListItem({ chat, onPress }: any) {
  return (
    <TouchableOpacity style={styles.container} onPress={onPress}>
      <View style={styles.avatar}>
        <Text style={styles.avatarText}>
          {chat.name?.charAt(0).toUpperCase() || "?"}
        </Text>
      </View>
      <View style={styles.content}>
        <View style={styles.header}>
          <Text style={styles.name} numberOfLines={1}>{chat.name}</Text>
          <Text style={styles.time}>{chat.last_message_time || ""}</Text>
        </View>
        <View style={styles.footer}>
          <Text style={styles.message} numberOfLines={1}>
            {chat.last_message || "Нет сообщений"}
          </Text>
          {chat.unread > 0 && (
            <View style={styles.badge}>
              <Text style={styles.badgeText}>{chat.unread}</Text>
            </View>
          )}
        </View>
      </View>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  container: { flexDirection: "row", padding: 12, alignItems: "center" },
  avatar: { width: 54, height: 54, borderRadius: 27, backgroundColor: "#2AABEE", alignItems: "center", justifyContent: "center" },
  avatarText: { color: "#FFF", fontSize: 22, fontWeight: "bold" },
  content: { flex: 1, marginLeft: 12 },
  header: { flexDirection: "row", justifyContent: "space-between", alignItems: "center" },
  name: { color: "#FFF", fontSize: 16, fontWeight: "600", flex: 1 },
  time: { color: "#708499", fontSize: 12, marginLeft: 8 },
  footer: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", marginTop: 4 },
  message: { color: "#708499", fontSize: 14, flex: 1 },
  badge: { backgroundColor: "#2AABEE", borderRadius: 10, minWidth: 20, height: 20, alignItems: "center", justifyContent: "center", paddingHorizontal: 6, marginLeft: 8 },
  badgeText: { color: "#FFF", fontSize: 12, fontWeight: "bold" },
});
'@
Set-Content -Path "$COMPONENTS\ChatListItem.tsx" -Value $chatItem -Encoding UTF8
Write-Host "[+] ChatListItem.tsx" -ForegroundColor Green

# ============ MESSAGE BUBBLE ============
$messageBubble = @'
import React from "react";
import { View, Text, StyleSheet } from "react-native";

export default function MessageBubble({ message, isOwn }: any) {
  return (
    <View style={[styles.container, isOwn ? styles.own : styles.other]}>
      {!isOwn && <Text style={styles.author}>{message.username}</Text>}
      <Text style={styles.text}>{message.text}</Text>
      <View style={styles.footer}>
        <Text style={styles.time}>
          {new Date(message.created_at).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}
        </Text>
        {isOwn && <Text style={styles.check}>✓✓</Text>}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { maxWidth: "80%", padding: 8, paddingHorizontal: 12, borderRadius: 12, marginBottom: 4 },
  own: { alignSelf: "flex-end", backgroundColor: "#2B5278", borderBottomRightRadius: 4 },
  other: { alignSelf: "flex-start", backgroundColor: "#182533", borderBottomLeftRadius: 4 },
  author: { color: "#2AABEE", fontSize: 12, fontWeight: "600", marginBottom: 2 },
  text: { color: "#FFF", fontSize: 16 },
  footer: { flexDirection: "row", justifyContent: "flex-end", alignItems: "center", marginTop: 2 },
  time: { color: "#708499", fontSize: 11, marginRight: 4 },
  check: { color: "#2AABEE", fontSize: 12 },
});
'@
Set-Content -Path "$COMPONENTS\MessageBubble.tsx" -Value $messageBubble -Encoding UTF8
Write-Host "[+] MessageBubble.tsx" -ForegroundColor Green

# ============ CHATS SCREEN ============
$chatsScreen = @'
import React, { useEffect, useState } from "react";
import { View, Text, FlatList, TouchableOpacity, StyleSheet, TextInput, Modal, Alert } from "react-native";
import { getChats, createChat } from "../api/api";
import ChatListItem from "../components/ChatListItem";

export default function ChatsScreen({ navigation }: any) {
  const [chats, setChats] = useState<any[]>([]);
  const [search, setSearch] = useState("");
  const [modalVisible, setModalVisible] = useState(false);
  const [newChatName, setNewChatName] = useState("");

  const loadChats = async () => {
    try {
      const data = await getChats();
      setChats(data);
    } catch (e) {}
  };

  useEffect(() => {
    loadChats();
    const interval = setInterval(loadChats, 3000);
    return () => clearInterval(interval);
  }, []);

  const handleCreate = async () => {
    if (!newChatName.trim()) { Alert.alert("Ошибка", "Введи название"); return; }
    try {
      await createChat(newChatName);
      setNewChatName("");
      setModalVisible(false);
      loadChats();
    } catch (e) { Alert.alert("Ошибка", "Не удалось создать"); }
  };

  const filtered = chats.filter((c) => c.name?.toLowerCase().includes(search.toLowerCase()));

  return (
    <View style={styles.container}>
      <View style={styles.searchBar}>
        <Text style={styles.searchIcon}>🔍</Text>
        <TextInput style={styles.searchInput} placeholder="Поиск" placeholderTextColor="#708499" value={search} onChangeText={setSearch} />
      </View>
      <FlatList
        data={filtered}
        keyExtractor={(item) => item.id.toString()}
        renderItem={({ item }) => (
          <ChatListItem chat={item} onPress={() => navigation.navigate("Chat", { chat: item })} />
        )}
        ItemSeparatorComponent={() => <View style={styles.separator} />}
      />
      <TouchableOpacity style={styles.fab} onPress={() => setModalVisible(true)}>
        <Text style={styles.fabIcon}>✏️</Text>
      </TouchableOpacity>
      <Modal visible={modalVisible} transparent animationType="slide">
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>Новый чат</Text>
            <TextInput style={styles.modalInput} placeholder="Название" placeholderTextColor="#708499" value={newChatName} onChangeText={setNewChatName} />
            <View style={styles.modalButtons}>
              <TouchableOpacity style={styles.modalButton} onPress={() => setModalVisible(false)}>
                <Text style={styles.modalButtonText}>Отмена</Text>
              </TouchableOpacity>
              <TouchableOpacity style={[styles.modalButton, styles.modalButtonPrimary]} onPress={handleCreate}>
                <Text style={styles.modalButtonText}>Создать</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#17212B" },
  searchBar: { flexDirection: "row", alignItems: "center", backgroundColor: "#0E1621", margin: 8, borderRadius: 10, paddingHorizontal: 12 },
  searchIcon: { fontSize: 16, marginRight: 8 },
  searchInput: { flex: 1, color: "#FFF", fontSize: 16, paddingVertical: 10 },
  separator: { height: 0.5, backgroundColor: "#101921", marginLeft: 78 },
  fab: { position: "absolute", bottom: 20, right: 20, width: 56, height: 56, borderRadius: 28, backgroundColor: "#2AABEE", alignItems: "center", justifyContent: "center", elevation: 5 },
  fabIcon: { fontSize: 24 },
  modalOverlay: { flex: 1, backgroundColor: "rgba(0,0,0,0.5)", justifyContent: "flex-end" },
  modalContent: { backgroundColor: "#17212B", borderTopLeftRadius: 20, borderTopRightRadius: 20, padding: 20 },
  modalTitle: { color: "#FFF", fontSize: 20, fontWeight: "bold", marginBottom: 20 },
  modalInput: { backgroundColor: "#0E1621", color: "#FFF", padding: 15, borderRadius: 10, fontSize: 16, marginBottom: 20 },
  modalButtons: { flexDirection: "row", justifyContent: "flex-end", gap: 10 },
  modalButton: { paddingVertical: 12, paddingHorizontal: 20, borderRadius: 10 },
  modalButtonPrimary: { backgroundColor: "#2AABEE" },
  modalButtonText: { color: "#FFF", fontSize: 16, fontWeight: "bold" },
});
'@
Set-Content -Path "$SCREENS\ChatsScreen.tsx" -Value $chatsScreen -Encoding UTF8
Write-Host "[+] ChatsScreen.tsx" -ForegroundColor Green

# ============ CHAT SCREEN ============
$chatScreen = @'
import React, { useEffect, useState, useRef } from "react";
import { View, Text, TextInput, TouchableOpacity, FlatList, StyleSheet, KeyboardAvoidingView, Platform, Alert, Modal } from "react-native";
import { getMessages, sendMessage, addReaction, deleteMessage, editMessage } from "../api/api";
import MessageBubble from "../components/MessageBubble";

export default function ChatScreen({ route }: any) {
  const { chat } = route.params;
  const [messages, setMessages] = useState<any[]>([]);
  const [text, setText] = useState("");
  const [editing, setEditing] = useState<any>(null);
  const [selected, setSelected] = useState<any>(null);
  const [modalVisible, setModalVisible] = useState(false);
  const flatListRef = useRef<FlatList>(null);

  const loadMessages = async () => {
    try {
      const data = await getMessages(chat.id);
      setMessages(data);
    } catch (e) {}
  };

  useEffect(() => {
    loadMessages();
    const interval = setInterval(loadMessages, 2000);
    return () => clearInterval(interval);
  }, []);

  const handleSend = async () => {
    if (!text.trim()) return;
    try {
      if (editing) {
        await editMessage(editing.id, text);
        setEditing(null);
      } else {
        await sendMessage(chat.id, text);
      }
      setText("");
      loadMessages();
      flatListRef.current?.scrollToEnd();
    } catch (e) {}
  };

  const handleLongPress = (msg: any) => {
    setSelected(msg);
    setModalVisible(true);
  };

  const handleReaction = async (emoji: string) => {
    if (selected) {
      await addReaction(selected.id, emoji);
      setModalVisible(false);
      loadMessages();
    }
  };

  const handleDelete = async () => {
    if (selected) {
      Alert.alert("Удалить", "Удалить сообщение?", [
        { text: "Нет", style: "cancel" },
        { text: "Да", style: "destructive", onPress: async () => { await deleteMessage(selected.id); setModalVisible(false); loadMessages(); } },
      ]);
    }
  };

  const handleEdit = () => {
    if (selected) { setEditing(selected); setText(selected.text); setModalVisible(false); }
  };

  return (
    <KeyboardAvoidingView style={styles.container} behavior={Platform.OS === "ios" ? "padding" : undefined}>
      <Text style={styles.chatTitle}>{chat.name}</Text>
      <FlatList
        ref={flatListRef}
        data={messages}
        keyExtractor={(item) => item.id.toString()}
        renderItem={({ item }) => (
          <TouchableOpacity onLongPress={() => handleLongPress(item)}>
            <MessageBubble message={item} isOwn={item.is_own} />
          </TouchableOpacity>
        )}
        style={styles.messages}
      />
      {editing && (
        <View style={styles.editingBar}>
          <Text style={styles.editingText}>Редактирование</Text>
          <TouchableOpacity onPress={() => { setEditing(null); setText(""); }}>
            <Text style={styles.cancelEdit}>✕</Text>
          </TouchableOpacity>
        </View>
      )}
      <View style={styles.inputRow}>
        <TextInput style={styles.input} placeholder="Сообщение..." placeholderTextColor="#708499" value={text} onChangeText={setText} multiline />
        <TouchableOpacity style={styles.sendButton} onPress={handleSend}>
          <Text style={styles.sendText}>➤</Text>
        </TouchableOpacity>
      </View>
      <Modal visible={modalVisible} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>Действия</Text>
            <View style={styles.reactionsRow}>
              {["👍", "❤️", "😂", "😮", "😢", "🔥"].map((emoji) => (
                <TouchableOpacity key={emoji} onPress={() => handleReaction(emoji)}>
                  <Text style={styles.reactionBtn}>{emoji}</Text>
                </TouchableOpacity>
              ))}
            </View>
            <TouchableOpacity style={styles.modalBtn} onPress={handleEdit}>
              <Text style={styles.modalBtnText}>✏️ Редактировать</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.modalBtn} onPress={handleDelete}>
              <Text style={styles.modalBtnText}>🗑️ Удалить</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.modalBtn} onPress={() => setModalVisible(false)}>
              <Text style={styles.modalBtnText}>Отмена</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#0E1621" },
  chatTitle: { fontSize: 18, fontWeight: "bold", color: "#FFF", padding: 15, backgroundColor: "#17212B", borderBottomWidth: 1, borderBottomColor: "#101921" },
  messages: { flex: 1, padding: 10 },
  inputRow: { flexDirection: "row", padding: 10, backgroundColor: "#17212B", alignItems: "flex-end" },
  input: { flex: 1, backgroundColor: "#0E1621", color: "#FFF", padding: 12, borderRadius: 20, fontSize: 16, maxHeight: 100 },
  sendButton: { backgroundColor: "#2AABEE", width: 44, height: 44, borderRadius: 22, alignItems: "center", justifyContent: "center", marginLeft: 8 },
  sendText: { color: "#FFF", fontSize: 20 },
  editingBar: { flexDirection: "row", justifyContent: "space-between", padding: 10, backgroundColor: "#1C2733" },
  editingText: { color: "#2AABEE", fontSize: 14 },
  cancelEdit: { color: "#FF3333", fontSize: 18 },
  modalOverlay: { flex: 1, backgroundColor: "rgba(0,0,0,0.7)", justifyContent: "center", alignItems: "center" },
  modalContent: { backgroundColor: "#17212B", borderRadius: 15, padding: 20, width: "80%" },
  modalTitle: { color: "#FFF", fontSize: 18, fontWeight: "bold", marginBottom: 15, textAlign: "center" },
  reactionsRow: { flexDirection: "row", justifyContent: "space-around", marginBottom: 15 },
  reactionBtn: { fontSize: 28 },
  modalBtn: { padding: 12, borderTopWidth: 1, borderTopColor: "#101921" },
  modalBtnText: { color: "#FFF", fontSize: 16, textAlign: "center" },
});
'@
Set-Content -Path "$SCREENS\ChatScreen.tsx" -Value $chatScreen -Encoding UTF8
Write-Host "[+] ChatScreen.tsx" -ForegroundColor Green

# ============ PROFILE SCREEN ============
$profileScreen = @'
import React, { useEffect, useState } from "react";
import { View, Text, TextInput, TouchableOpacity, StyleSheet, ScrollView, Alert, Switch } from "react-native";
import { getMe, logout, updateProfile, updateTheme, updatePrivacy } from "../api/api";

export default function ProfileScreen({ navigation }: any) {
  const [user, setUser] = useState<any>(null);
  const [bio, setBio] = useState("");
  const [theme, setTheme] = useState("dark");
  const [hideLastSeen, setHideLastSeen] = useState(false);
  const [hidePhone, setHidePhone] = useState(false);
  const [hideAvatar, setHideAvatar] = useState(false);

  useEffect(() => {
    getMe().then((data) => {
      setUser(data);
      setBio(data.bio || "");
      setTheme(data.theme || "dark");
    }).catch(() => {});
  }, []);

  const handleSaveBio = async () => {
    try { await updateProfile({ bio }); Alert.alert("Успех", "Био обновлено"); }
    catch (e) { Alert.alert("Ошибка", "Не удалось сохранить"); }
  };

  const handleLogout = async () => {
    await logout();
    navigation.replace("Login");
  };

  return (
    <ScrollView style={styles.container}>
      <Text style={styles.title}>Профиль</Text>
      {user && (
        <>
          <View style={styles.section}>
            <Text style={styles.label}>Имя пользователя</Text>
            <Text style={styles.value}>{user.username}</Text>
          </View>
          <View style={styles.section}>
            <Text style={styles.label}>Био</Text>
            <TextInput style={styles.input} value={bio} onChangeText={setBio} placeholder="Расскажи о себе..." placeholderTextColor="#708499" multiline />
            <TouchableOpacity style={styles.saveBtn} onPress={handleSaveBio}>
              <Text style={styles.saveBtnText}>Сохранить</Text>
            </TouchableOpacity>
          </View>
        </>
      )}
      <TouchableOpacity style={styles.logoutBtn} onPress={handleLogout}>
        <Text style={styles.logoutText}>Выйти</Text>
      </TouchableOpacity>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#17212B", padding: 20 },
  title: { fontSize: 32, fontWeight: "bold", color: "#2AABEE", textAlign: "center", marginBottom: 30 },
  section: { marginBottom: 25 },
  label: { color: "#708499", fontSize: 14, marginBottom: 8 },
  value: { color: "#FFF", fontSize: 18 },
  input: { backgroundColor: "#0E1621", color: "#FFF", padding: 12, borderRadius: 10, fontSize: 16, minHeight: 80 },
  saveBtn: { backgroundColor: "#2AABEE", padding: 12, borderRadius: 10, alignItems: "center", marginTop: 10 },
  saveBtnText: { color: "#FFF", fontSize: 16, fontWeight: "bold" },
  logoutBtn: { backgroundColor: "#FF3333", padding: 15, borderRadius: 10, alignItems: "center", marginTop: 20 },
  logoutText: { color: "#FFF", fontSize: 18, fontWeight: "bold" },
});
'@
Set-Content -Path "$SCREENS\ProfileScreen.tsx" -Value $profileScreen -Encoding UTF8
Write-Host "[+] ProfileScreen.tsx" -ForegroundColor Green

# ============ SETTINGS SCREEN ============
$settingsScreen = @'
import React, { useState } from "react";
import { View, Text, StyleSheet, Switch, ScrollView } from "react-native";

export default function SettingsScreen() {
  const [notifications, setNotifications] = useState(true);
  const [sounds, setSounds] = useState(true);
  const [vibration, setVibration] = useState(true);

  return (
    <ScrollView style={styles.container}>
      <Text style={styles.title}>Настройки</Text>
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Уведомления</Text>
        <View style={styles.row}>
          <Text style={styles.label}>Push-уведомления</Text>
          <Switch value={notifications} onValueChange={setNotifications} />
        </View>
        <View style={styles.row}>
          <Text style={styles.label}>Звуки</Text>
          <Switch value={sounds} onValueChange={setSounds} />
        </View>
        <View style={styles.row}>
          <Text style={styles.label}>Вибрация</Text>
          <Switch value={vibration} onValueChange={setVibration} />
        </View>
      </View>
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>О приложении</Text>
        <Text style={styles.info}>NEXUSCHAT v1.0.0</Text>
        <Text style={styles.info}>by Vitaly</Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#17212B", padding: 20 },
  title: { fontSize: 32, fontWeight: "bold", color: "#2AABEE", textAlign: "center", marginBottom: 30 },
  section: { marginBottom: 25 },
  sectionTitle: { color: "#2AABEE", fontSize: 18, fontWeight: "bold", marginBottom: 15 },
  row: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", paddingVertical: 10 },
  label: { color: "#FFF", fontSize: 16 },
  info: { color: "#708499", fontSize: 14, textAlign: "center", marginBottom: 5 },
});
'@
Set-Content -Path "$SCREENS\SettingsScreen.tsx" -Value $settingsScreen -Encoding UTF8
Write-Host "[+] SettingsScreen.tsx" -ForegroundColor Green

# ============ APP.TSX ============
$appTsx = @'
import React from "react";
import { NavigationContainer } from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";
import LoginScreen from "./src/screens/LoginScreen";
import RegisterScreen from "./src/screens/RegisterScreen";
import ChatsScreen from "./src/screens/ChatsScreen";
import ChatScreen from "./src/screens/ChatScreen";
import ProfileScreen from "./src/screens/ProfileScreen";
import SettingsScreen from "./src/screens/SettingsScreen";

const Stack = createNativeStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName="Login"
        screenOptions={{
          headerStyle: { backgroundColor: "#17212B" },
          headerTintColor: "#2AABEE",
          headerTitleStyle: { fontWeight: "bold" },
        }}
      >
        <Stack.Screen name="Login" component={LoginScreen} options={{ headerShown: false }} />
        <Stack.Screen name="Register" component={RegisterScreen} options={{ headerShown: false }} />
        <Stack.Screen name="Chats" component={ChatsScreen} options={{ title: "NEXUSCHAT" }} />
        <Stack.Screen name="Chat" component={ChatScreen} />
        <Stack.Screen name="Profile" component={ProfileScreen} options={{ title: "Профиль" }} />
        <Stack.Screen name="Settings" component={SettingsScreen} options={{ title: "Настройки" }} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
'@
Set-Content -Path "$BASE\App.tsx" -Value $appTsx -Encoding UTF8
Write-Host "[+] App.tsx" -ForegroundColor Green

# ============ APP.JSON ============
$appJson = @'
{
  "name": "NEXUSCHAT",
  "displayName": "NEXUSCHAT"
}
'@
Set-Content -Path "$BASE\app.json" -Value $appJson -Encoding UTF8
Write-Host "[+] app.json" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NEXUSCHAT — ВСЁ ГОТОВО!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Теперь:" -ForegroundColor Yellow
Write-Host "  1. cd E:\SkaryChatApp\android" -ForegroundColor White
Write-Host "  2. gradlew.bat assembleDebug" -ForegroundColor White
Write-Host ""
Write-Host "APK будет в: android\app\build\outputs\apk\debug\app-debug.apk" -ForegroundColor White
Write-Host ""