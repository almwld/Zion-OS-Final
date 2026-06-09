import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:riverpod/riverpod.dart';

final unifiedCoreProvider = Provider<UnifiedCoreService>((ref) => UnifiedCoreService());

class UnifiedCoreService {
  Future<String> execute(String command, {String? target, Map<String, String>? options}) async {
    try {
      switch (command) {
        case 'ping':
          return await _ping(target ?? '127.0.0.1');
        case 'port_scan':
          return await _portScan(target ?? '127.0.0.1');
        case 'dns_lookup':
          return await _dnsLookup(target ?? 'google.com');
        case 'http_headers':
          return await _httpHeaders(target ?? 'http://google.com');
        case 'system_info':
          return _systemInfo();
        case 'help':
          return _helpText();
        default:
          return 'Unknown command: $command\nType "help" for commands.';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> _ping(String target) async {
    try {
      final result = await Process.run('ping', ['-c', '4', target], runInShell: true);
      return result.stdout.toString();
    } catch (e) {
      return 'Ping failed: $e';
    }
  }

  Future<String> _portScan(String target) async {
    final ports = [21, 22, 23, 25, 53, 80, 443, 8080, 8443];
    final openPorts = <String>[];
    for (final port in ports) {
      try {
        final socket = await Socket.connect(target, port, timeout: const Duration(milliseconds: 500));
        openPorts.add('$port (open)');
        socket.destroy();
      } catch (_) {}
    }
    return 'Port scan on $target:\n${openPorts.isNotEmpty ? openPorts.join('\n') : "No open ports found"}';
  }

  Future<String> _dnsLookup(String domain) async {
    try {
      final addresses = await InternetAddress.lookup(domain);
      return 'DNS Lookup for $domain:\n${addresses.map((a) => '${a.address} (${a.type.name})').join('\n')}';
    } catch (e) {
      return 'DNS Lookup failed: $e';
    }
  }

  Future<String> _httpHeaders(String url) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      final headers = response.headers;
      final output = StringBuffer();
      headers.forEach((name, values) => output.writeln('$name: ${values.join(', ')}'));
      return 'HTTP Headers for $url:\n$output';
    } catch (e) {
      return 'HTTP Headers failed: $e';
    }
  }

  String _systemInfo() => '''
System Information:
  OS: ${Platform.operatingSystem}
  Version: ${Platform.operatingSystemVersion}
  CPU: ${Platform.numberOfProcessors} cores
  Dart: ${Platform.version}
''';

  String _helpText() => '''
=== PROJECT ZION ===
ping <ip>        - Ping host
port_scan <ip>   - Scan ports
dns_lookup <d>   - DNS lookup
http_headers <u> - HTTP headers
system_info      - System info
help             - Show help
==================
''';
}
