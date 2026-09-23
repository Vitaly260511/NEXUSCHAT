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

