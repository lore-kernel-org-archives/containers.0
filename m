From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: Re: [PATCH v4 0/4] cgroup notifications API and memory thresholds
Date: Sun, 27 Dec 2009 20:37:57 +0200
Message-ID: <cc557aab0912271037scb29fe1xcebe9adfaea97b24__11765.5868911699$1261939218$gmane$org@mail.gmail.com>
References: <cover.1261858972.git.kirill@shutemov.name>
	<20091227124732.GA3601@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0050450170486e6345047bba16b3
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091227124732.GA3601-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: Alexander Shishkin <virtuoso-0lOfPCoBze7YtjvyW6yDsg@public.gmane.org>, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

--0050450170486e6345047bba16b3
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Sun, Dec 27, 2009 at 2:47 PM, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> w=
rote:
> * Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> [2009-12-27 04:08:58]:
>
>> This patchset introduces eventfd-based API for notifications in cgroups =
and
>> implements memory notifications on top of it.
>>
>> It uses statistics in memory controler to track memory usage.
>>
>> Output of time(1) on building kernel on tmpfs:
>>
>> Root cgroup before changes:
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0506.37 user 60.93s system 193% cpu 4=
:52.77 total
>> Non-root cgroup before changes:
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0507.14 user 62.66s system 193% cpu 4=
:54.74 total
>> Root cgroup after changes (0 thresholds):
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0507.13 user 62.20s system 193% cpu 4=
:53.55 total
>> Non-root cgroup after changes (0 thresholds):
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0507.70 user 64.20s system 193% cpu 4=
:55.70 total
>> Root cgroup after changes (1 thresholds, never crossed):
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0506.97 user 62.20s system 193% cpu 4=
:53.90 total
>> Non-root cgroup after changes (1 thresholds, never crossed):
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0507.55 user 64.08s system 193% cpu 4=
:55.63 total
>>
>> Any comments?
>
> Thanks for adding the documentation, now on to more critical questions
>
> 1. Any reasons for not using cgroupstats?

Could you explain the idea? I don't see how cgroupstats applicable for
the task.

> 2. Is there a user space test application to test this code.

Attached. It's not very clean, but good enough for testing propose.
Example of usage:

$ echo '/cgroups/memory.usage_in_bytes 1G' | ./cgroup_event_monitor

> =C2=A0IIUC,
> I need to write a program that uses eventfd(2) and then passes
> the eventfd descriptor and thresold to cgroup.*event* file and
> then the program will get notified when the threshold is reached?

You need to pass eventfd descriptor, descriptor of control file to be
monitored (memory.usage_in_bytes or memory.memsw.usage_in_bytes) and
threshold.

Do you want to rename cgroup.event_control to cgroup.event?

--0050450170486e6345047bba16b3
Content-Type: application/octet-stream; name="cgroup_event_monitor.c"
Content-Disposition: attachment; filename="cgroup_event_monitor.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g3q5oq4k0

I2RlZmluZSBfR05VX1NPVVJDRQoKI2luY2x1ZGUgPGFzc2VydC5oPgojaW5jbHVkZSA8ZXJybm8u
aD4KI2luY2x1ZGUgPGZjbnRsLmg+CiNpbmNsdWRlIDxsaWJnZW4uaD4KI2luY2x1ZGUgPGxpbWl0
cy5oPgojaW5jbHVkZSA8cG9sbC5oPgojaW5jbHVkZSA8c3RkaW8uaD4KI2luY2x1ZGUgPHN0ZGxp
Yi5oPgojaW5jbHVkZSA8c3RyaW5nLmg+CiNpbmNsdWRlIDx1bmlzdGQuaD4KI2luY2x1ZGUgPHN5
cy9ldmVudGZkLmg+CgojZGVmaW5lIE1BWF9FRkQgMTAwCgpzdHJ1Y3QgZXZlbnQgewoJY2hhciAq
cGF0aDsKCWNoYXIgKmFyZ3M7Cn07CgppbnQgbWFpbihpbnQgYXJnYywgY2hhciAqKmFyZ3YpCnsK
CXN0cnVjdCBldmVudCBldmVudHNbTUFYX0VGRF07CglzdHJ1Y3QgcG9sbGZkIHBvbGxmZHNbTUFY
X0VGRF07CglpbnQgbiA9IDA7CgljaGFyIGxpbmVbUEFUSF9NQVhdOwoJaW50IHJldDsKCgl3aGls
ZSAoZmdldHMobGluZSwgUEFUSF9NQVgsIHN0ZGluKSkgewoJCWludCBldmVudF9jb250cm9sLCBj
ZmQ7CgkJY2hhciAqYXJncyA9IHN0cmNocm51bChsaW5lLCAnICcpOwoKCQlpZiAobiA+PSBNQVhf
RUZEKSB7CgkJCWZwcmludGYoc3RkZXJyLCAiVG9vIG1hbnkgZXZlbnRzIHJlZ2lzdGVyZWRcbiIp
OwoJCX0KCgkJaWYgKCphcmdzKQoJCQkqYXJncysrID0gJ1wwJzsKCgkJZXZlbnRzW25dLnBhdGgg
PSBtYWxsb2Moc3RybGVuKGxpbmUpICsgMSk7CgkJYXNzZXJ0KGV2ZW50c1tuXS5wYXRoKTsKCQlz
dHJjcHkoZXZlbnRzW25dLnBhdGgsIGxpbmUpOwoKCQlhcmdzW3N0cmxlbihhcmdzKSAtIDFdID0g
J1wwJzsKCQlldmVudHNbbl0uYXJncyA9IG1hbGxvYyhzdHJsZW4oYXJncykgKyAxKTsKCQlhc3Nl
cnQoZXZlbnRzW25dLmFyZ3MpOwoJCXN0cmNweShldmVudHNbbl0uYXJncywgYXJncyk7CgoJCWNm
ZCA9IG9wZW4oZXZlbnRzW25dLnBhdGgsIE9fUkRPTkxZKTsKCQlpZiAoY2ZkIDwgMCkgewoJCQlm
cHJpbnRmKHN0ZGVyciwgIkNhbm5vdCBvcGVuICVzOiAlc1xuIiwgZXZlbnRzW25dLnBhdGgsCgkJ
CQkJc3RyZXJyb3IoZXJybm8pKTsKCQkJcmV0dXJuIDE7CgkJfQoKCQlwb2xsZmRzW25dLmV2ZW50
cyA9IFBPTExJTjsKCQlwb2xsZmRzW25dLmZkID0gZXZlbnRmZCgwLCAwKTsKCgkJZGlybmFtZShs
aW5lKTsKCQlzdHJjYXQobGluZSwgIi9jZ3JvdXAuZXZlbnRfY29udHJvbCIpOwoKCQlldmVudF9j
b250cm9sID0gb3BlbihsaW5lLCBPX1dST05MWSk7CgkJaWYgKGV2ZW50X2NvbnRyb2wgPCAwKSB7
CgkJCWZwcmludGYoc3RkZXJyLCAiQ2Fubm90IG9wZW4gJXM6ICVzXG4iLCBsaW5lLAoJCQkJCXN0
cmVycm9yKGVycm5vKSk7CgkJCXJldHVybiAxOwoJCX0KCgkJc25wcmludGYobGluZSwgUEFUSF9N
QVgsICIlZCAlZCAlc1xuIiwgcG9sbGZkc1tuXS5mZCwgY2ZkLAoJCQkJZXZlbnRzW25dLmFyZ3Mp
OwoKCQlpZiAod3JpdGUoZXZlbnRfY29udHJvbCwgbGluZSwgc3RybGVuKGxpbmUpKSA8IDApIHsK
CQkJZnByaW50ZihzdGRlcnIsICJDYW5ub3Qgd3JpdGUgdG8gY2dyb3VwLmV2ZW50X2NvbnRyb2w6
ICVzXG4iLAoJCQkJCXN0cmVycm9yKGVycm5vKSk7CgkJCXJldHVybiAxOwoJCX0KCgkJY2xvc2Uo
ZXZlbnRfY29udHJvbCk7CgkJY2xvc2UoY2ZkKTsKCgkJbisrOwoJfQoKCXdoaWxlKChyZXQgPSBw
b2xsKHBvbGxmZHMsIG4sIC0xKSkgIT0gMCkgewoJCWludCBpOwoKCQlpZiAocmV0IDwgMCkgewoJ
CQlwZXJyb3IoInBvbGwoKSIpOwoJCQlyZXR1cm4gMTsKCQl9CgoJCWZvcihpPTA7IChpIDwgbikg
JiYgcmV0OyBpKyspIHsKCQkJaWYgKHBvbGxmZHNbaV0ucmV2ZW50cyAmIFBPTExJTikgewoJCQkJ
cHJpbnRmKCIlcyAlc1xuIiwgZXZlbnRzW2ldLnBhdGgsCgkJCQkJCWV2ZW50c1tpXS5hcmdzKTsK
CQkJCWlmIChyZWFkKHBvbGxmZHNbaV0uZmQsIGxpbmUsIDgpIDwgMCkgewoJCQkJCXBlcnJvcigi
cmVhZCgpIik7CgkJCQkJcmV0dXJuIDE7CgkJCQl9CgkJCQlyZXQtLTsKCQkJfQoKCQkJaWYgKHBv
bGxmZHNbaV0ucmV2ZW50cyAmIH4oUE9MTElOKSkgewoJCQkJcHJpbnRmKCIlcyglcyk6IHVuZXhw
ZWN0ZWQgZXZlbnQ6ICUwOHhcbiIsCgkJCQkJCWV2ZW50c1tpXS5wYXRoLAoJCQkJCQlldmVudHNb
aV0uYXJncywKCQkJCQkJcG9sbGZkc1tpXS5yZXZlbnRzKTsKCQkJCXJldHVybiAxOwoJCQl9CgkJ
fQoJfQoKCXJldHVybiAwOwp9Cg==
--0050450170486e6345047bba16b3
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--0050450170486e6345047bba16b3--
