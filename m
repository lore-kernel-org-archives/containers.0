From: Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC PATCH v3 1/3] ima: extend clone() with IMA namespace support
Date: Fri, 13 Apr 2018 12:25:02 -0400
Message-ID: <1523636702.3272.63.camel__14003.7386831411$1523636632$gmane$org@linux.vnet.ibm.com>
References: <1522159038-14175-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<1522159038-14175-2-git-send-email-stefanb@linux.vnet.ibm.com>
	<87sh8lcecn.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87sh8lcecn.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org, Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, david.safford-JJi787mZWgc@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, John Johansen <john.johansen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, linux-integrity-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

W0NjJ2luZyBKb2huIEpvaGFuc2VuXQoKT24gVHVlLCAyMDE4LTAzLTI3IGF0IDE4OjAxIC0wNTAw
LCBFcmljIFcuIEJpZWRlcm1hbiB3cm90ZToKWy4uLl0KPiBBcyBzdWNoIEkgZXhwZWN0IHRoZSBi
ZXN0IHdheSB0byBjcmVhdGUgdGhlIGltYSBuYW1lc3BhY2UgaXMgYnkgc2ltcGx5Cj4gd3JpdGlu
ZyB0byBzZWN1cml0eWZzL2ltYWZzLiAgUG9zc2libHkgYmVmb3JlIHRoZSB1c2VyIG5hbWVzcGFj
ZSBpcwo+IGV2ZW4gdW5zaGFyZWQuICBUaGF0IHdvdWxkIGFsbG93IElNQSB0byBrZWVwIHRyYWNr
IG9mIHRoaW5ncyBmcm9tCj4gYmVmb3JlIGEgY29udGFpbmVyIGlzIGNyZWF0ZWQuCgpNeSBpbml0
aWFsIHRob3VnaHQgd2FzIHRvIHN0YWdlIElNQSBuYW1lc3BhY2luZyB3aXRoIGp1c3QgSU1BLWF1
ZGl0CmZpcnN0LCBmb2xsb3dlZCBieSBlaXRoZXIgSU1BLW1lYXN1cmVtZW50IG9yIElNQS1hcHBy
YWlzYWwuIMKgVGhpcwp3b3VsZCBhbGxvdyB1cyB0byBnZXQgdGhlIGJhc2ljIElNQSBuYW1lc3Bh
Y2luZyBmcmFtZXdvcmsgd29ya2luZyBhbmQKZGVmZXIgZGVhbGluZyB3aXRoIHRoZSBzZWN1cml0
eWZzIHJlbGF0ZWQgbmFtZXNwYWNpbmcgb2YgdGhlIElNQQpwb2xpY3kgYW5kIG1lYXN1cmVtZW50
IGxpc3QgaXNzdWVzIHRvIGxhdGVyLgoKQnkgdHlpbmcgSU1BIG5hbWVzcGFjaW5nIHRvIGEgc2Vj
dXJpdHlmcyBpbWEvdW5zaGFyZSBmaWxlLCB3ZSB3b3VsZApuZWVkIHRvIGFkZHJlc3MgdGhlIHNl
Y3VyaXR5ZnMgaXNzdWVzIGZpcnN0LgoKTWltaQoKX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0Bs
aXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5v
cmcvbWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz
