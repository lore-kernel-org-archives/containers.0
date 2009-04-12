From: =?UTF-8?Q?M=C3=B4she_van_der_Sterre?= <me-A/3C56C7qwM@public.gmane.org>
Subject: BUG in tty_open when using containers and ptrace
Date: Sun, 12 Apr 2009 15:45:51 +0200
Message-ID: <d06d0dd6a4ddf760bea53291c048e291@[::1]>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

SGVsbG8sCgpJIGFtIHdvcmtpbmcgb24gdGhlIGx4YyB1c2Vyc3BhY2UgdG9vbHMsIGFuZCBnb3Qg
dGhpcyBCVUcgYSBjb3VwbGUgb2YKdGltZXMuCkhlcmUgYXJlIHRoZSByZXBvcnRzOgoKaHR0cDov
L21vc2hlLm5sL3R0eS1idWdzaG90MS5wbmcKaHR0cDovL21vc2hlLm5sL3R0eS1idWdzaG90Mi5w
bmcKCkkgYW0gcnVubmluZyAyLjYuMjkuMSBmcm9tIGtlcm5lbC5vcmcgaW4gYSB2aXJ0dWFsIG1h
Y2hpbmUgdW5kZXIga3ZtLgpJIGhhdmUgbm90IGJlZW4gYWJsZSB0byByZWxpYWJseSByZXByb2R1
Y2UgaXQsIGJ1dCBpdCBoYXBwZW5zIG9ubHkgYWZ0ZXIKdGhlIGNvbnRhaW5lciBpcyBzZXR1cCBh
bmQgcHRyYWNlIGlzIGFjdGl2ZSBvbiBseGMtc3RhcnQuCkkgdGhpbmsgdGhlIGZpcnN0IHNjcmVl
biBzaG90IGlzIHdoaWxlIGFsbCB0dHlzIHdoZXJlIGFsbG93ZWQgaW4KY2dyb3VwLmRldmljZXMs
IHRoZSBzZWNvbmQgb25lIHdoaWxlIG9ubHkgdHR5MSB3YXMgYWxsb3dlZC4KCkdyZWV0aW5ncywK
TcO0c2hlIHZhbiBkZXIgU3RlcnJlCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRhaW5lcnNAbGlzdHMubGlu
dXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZy9tYWls
bWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=
