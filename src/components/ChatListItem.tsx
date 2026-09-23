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
