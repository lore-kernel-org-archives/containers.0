From: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 2/6] Container Freezer: Make refrigerator always available
Date: Fri, 1 Aug 2008 16:27:12 +0200
Message-ID: <20080801162712.63721e8c__46046.5509714142$1217604894$gmane$org@surf>
References: <20080801050659.924495279@us.ibm.com>
	<20080801050700.528446138@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080801050700.528446138-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: linux-embedded-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michael Opdenacker <michael-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Linux-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

SGksCgpMZSBUaHUsIDMxIEp1bCAyMDA4IDIyOjA3OjAxIC0wNzAwLApNYXR0IEhlbHNsZXkgPG1h
dHRobHRjQHVzLmlibS5jb20+IGEgw6ljcml0IDoKCj4gLS0tIGEva2VybmVsL01ha2VmaWxlCj4g
KysrIGIva2VybmVsL01ha2VmaWxlCj4gQEAgLTUsNyArNSw3IEBACj4gIG9iai15ICAgICA9IHNj
aGVkLm8gZm9yay5vIGV4ZWNfZG9tYWluLm8gcGFuaWMubyBwcmludGsubyBcCj4gIAkgICAgY3B1
Lm8gZXhpdC5vIGl0aW1lci5vIHRpbWUubyBzb2Z0aXJxLm8gcmVzb3VyY2UubyBcCj4gIAkgICAg
c3lzY3RsLm8gY2FwYWJpbGl0eS5vIHB0cmFjZS5vIHRpbWVyLm8gdXNlci5vIFwKPiAtCSAgICBz
aWduYWwubyBzeXMubyBrbW9kLm8gd29ya3F1ZXVlLm8gcGlkLm8gXAo+ICsJICAgIHNpZ25hbC5v
IHN5cy5vIGttb2QubyB3b3JrcXVldWUubyBwaWQubyBmcmVlemVyLm8gXAoKSSBoYXZlIHRoZSBp
bXByZXNzaW9uIHRoYXQgdGhlIGNvZGUgaW4ga2VybmVsL3Bvd2VyL3Byb2Nlc3MuYyB3YXMKY29t
cGlsZWQgb25seSBpZiBDT05GSUdfUE1fU0xFRVAgd2FzIHNldC4gTm93IHRoYXQgdGhlIGNvZGUg
aGFzIGJlZW4KbW92ZWQgdG8ga2VybmVsL2ZyZWV6ZXIuYywgaXQgaXMgdW5jb25kaXRpb25uYWx5
IGNvbXBpbGVkIGluIGV2ZXJ5Cmtlcm5lbC4gSXMgdGhhdCBjb3JyZWN0ID8KCklmIHNvLCBpcyBp
dCBwb3NzaWJsZSB0byBwdXQgdGhpcyBuZXcgZmVhdHVyZSB1bmRlciBzb21lCkNPTkZJR19TT01F
VEhJTkcgb3B0aW9uLCBmb3IgcGVvcGxlIHdobyBjYXJlIGFib3V0IHRoZSBrZXJuZWwgc2l6ZSA/
CgpUaGFua3MsCgpUaG9tYXMKLS0gClRob21hcyBQZXRhenpvbmksIEZyZWUgRWxlY3Ryb25zCktl
cm5lbCwgZHJpdmVycyBhbmQgZW1iZWRkZWQgTGludXggZGV2ZWxvcG1lbnQsCmNvbnN1bHRpbmcs
IHRyYWluaW5nIGFuZCBzdXBwb3J0LgpodHRwOi8vZnJlZS1lbGVjdHJvbnMuY29tCl9fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGlu
ZyBsaXN0CkNvbnRhaW5lcnNAbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0
cy5saW51eC1mb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=
