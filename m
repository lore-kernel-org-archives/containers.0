From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Crash in mac-vlan driver ?
Date: Wed, 10 Feb 2010 19:23:26 -0800
Message-ID: <20100211032326.GA31163@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="9amGYk9869ThD9tj"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

I got a crash in LXC after running


	$ lxc-execute -n foo -f /usr/share/doc/lxc/examples/lxc-macvlan.conf

	$ ps -ef

	$ lxc-stop -n foo


Attached is the info that got printed on the console.

System is an x330, running RHEL5.2 with latest Checkpoint/Restart
patches (i.e following commit)

	commit ed96a92cdb74ba1e2c62a18a3254c049e06fe7aa
	Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
	Date:   Wed Jan 27 16:14:18 2010 -0500

Will try to repro without the C/R patchset.

--9amGYk9869ThD9tj
Content-Type: text/plain; charset=utf-8
Content-Description: mac-vlan.bug-1
Content-Disposition: attachment; filename="lxc.bug-1"
Content-Transfer-Encoding: quoted-printable


=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
BUG kmalloc-2048: Poison overwritten
BUG kmalloc-2048: Poison overwritten
---------------------------------------------------------------------------=
--
---------------------------------------------------------------------------=
--


INFO: 0xf6a24ca8-0xf6a24cab. First byte 0x0 instead of 0x6b
INFO: 0xf6a24ca8-0xf6a24cab. First byte 0x0 instead of 0x6b
INFO: Allocated in macvlan_newlink+0xba/0x1a0 age=3D22039 cpu=3D3 pid=3D188=
64
INFO: Allocated in macvlan_newlink+0xba/0x1a0 age=3D22039 cpu=3D3 pid=3D188=
64
INFO: Freed in default_device_exit_batch+0x2e/0x76 age=3D3832 cpu=3D1 pid=
=3D22
INFO: Freed in default_device_exit_batch+0x2e/0x76 age=3D3832 cpu=3D1 pid=
=3D22
INFO: Slab 0xc1d91400 objects=3D15 used=3D14 fp=3D0xf6a249b0 flags=3D0x3500=
40c3
INFO: Slab 0xc1d91400 objects=3D15 used=3D14 fp=3D0xf6a249b0 flags=3D0x3500=
40c3
INFO: Object 0xf6a249b0 @offset=3D18864 fp=3D0x(null)
INFO: Object 0xf6a249b0 @offset=3D18864 fp=3D0x(null)


Bytes b4 0xf6a249a0: Bytes b4 0xf6a249a0:  16 16 00 00 00 00 00 00 c9 c9 9c=
 9c 12 12 00 00 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a ....=EF=BF=
=BD...ZZZZZZZZ
 ....=EF=BF=BD...ZZZZZZZZ
  Object 0xf6a249b0:   Object 0xf6a249b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a249c0:   Object 0xf6a249c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a249d0:   Object 0xf6a249d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a249e0:   Object 0xf6a249e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a249f0:   Object 0xf6a249f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24a00:   Object 0xf6a24a00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24a10:   Object 0xf6a24a10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24a20:   Object 0xf6a24a20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24a30:   Object 0xf6a24a30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24a40:   Object 0xf6a24a40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24a50:   Object 0xf6a24a50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24a60:   Object 0xf6a24a60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24a70:   Object 0xf6a24a70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24a80:   Object 0xf6a24a80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24a90:   Object 0xf6a24a90:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24aa0:   Object 0xf6a24aa0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24ab0:   Object 0xf6a24ab0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24ac0:   Object 0xf6a24ac0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24ad0:   Object 0xf6a24ad0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24ae0:   Object 0xf6a24ae0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24af0:   Object 0xf6a24af0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24b00:   Object 0xf6a24b00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24b10:   Object 0xf6a24b10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24b20:   Object 0xf6a24b20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24b30:   Object 0xf6a24b30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24b40:   Object 0xf6a24b40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24b50:   Object 0xf6a24b50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24b60:   Object 0xf6a24b60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24b70:   Object 0xf6a24b70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24b80:   Object 0xf6a24b80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24b90:   Object 0xf6a24b90:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24ba0:   Object 0xf6a24ba0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24bb0:   Object 0xf6a24bb0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24bc0:   Object 0xf6a24bc0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24bd0:   Object 0xf6a24bd0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24be0:   Object 0xf6a24be0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24bf0:   Object 0xf6a24bf0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24c00:   Object 0xf6a24c00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24c10:   Object 0xf6a24c10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24c20:   Object 0xf6a24c20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24c30:   Object 0xf6a24c30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24c40:   Object 0xf6a24c40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24c50:   Object 0xf6a24c50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24c60:   Object 0xf6a24c60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24c70:   Object 0xf6a24c70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24c80:   Object 0xf6a24c80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24c90:   Object 0xf6a24c90:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24ca0:   Object 0xf6a24ca0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 00 00 00 00 00 00 00 00 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkk...=
=2Ekkkk
 kkkkkkkk....kkkk
  Object 0xf6a24cb0:   Object 0xf6a24cb0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24cc0:   Object 0xf6a24cc0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24cd0:   Object 0xf6a24cd0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24ce0:   Object 0xf6a24ce0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24cf0:   Object 0xf6a24cf0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24d00:   Object 0xf6a24d00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24d10:   Object 0xf6a24d10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24d20:   Object 0xf6a24d20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24d30:   Object 0xf6a24d30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24d40:   Object 0xf6a24d40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24d50:   Object 0xf6a24d50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24d60:   Object 0xf6a24d60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24d70:   Object 0xf6a24d70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24d80:   Object 0xf6a24d80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24d90:   Object 0xf6a24d90:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24da0:   Object 0xf6a24da0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24db0:   Object 0xf6a24db0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24dc0:   Object 0xf6a24dc0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24dd0:   Object 0xf6a24dd0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24de0:   Object 0xf6a24de0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24df0:   Object 0xf6a24df0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24e00:   Object 0xf6a24e00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24e10:   Object 0xf6a24e10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24e20:   Object 0xf6a24e20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24e30:   Object 0xf6a24e30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24e40:   Object 0xf6a24e40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24e50:   Object 0xf6a24e50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24e60:   Object 0xf6a24e60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24e70:   Object 0xf6a24e70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24e80:   Object 0xf6a24e80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24e90:   Object 0xf6a24e90:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24ea0:   Object 0xf6a24ea0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24eb0:   Object 0xf6a24eb0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24ec0:   Object 0xf6a24ec0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24ed0:   Object 0xf6a24ed0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24ee0:   Object 0xf6a24ee0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24ef0:   Object 0xf6a24ef0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24f00:   Object 0xf6a24f00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24f10:   Object 0xf6a24f10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24f20:   Object 0xf6a24f20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24f30:   Object 0xf6a24f30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24f40:   Object 0xf6a24f40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24f50:   Object 0xf6a24f50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24f60:   Object 0xf6a24f60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24f70:   Object 0xf6a24f70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24f80:   Object 0xf6a24f80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24f90:   Object 0xf6a24f90:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24fa0:   Object 0xf6a24fa0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24fb0:   Object 0xf6a24fb0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24fc0:   Object 0xf6a24fc0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24fd0:   Object 0xf6a24fd0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24fe0:   Object 0xf6a24fe0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a24ff0:   Object 0xf6a24ff0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a25000:   Object 0xf6a25000:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a25010:   Object 0xf6a25010:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a25020:   Object 0xf6a25020:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a25030:   Object 0xf6a25030:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a25040:   Object 0xf6a25040:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a25050:   Object 0xf6a25050:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a25060:   Object 0xf6a25060:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a25070:   Object 0xf6a25070:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a25080:   Object 0xf6a25080:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a25090:   Object 0xf6a25090:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a250a0:   Object 0xf6a250a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a250b0:   Object 0xf6a250b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a250c0:   Object 0xf6a250c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a250d0:   Object 0xf6a250d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a250e0:   Object 0xf6a250e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a250f0:   Object 0xf6a250f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a25100:   Object 0xf6a25100:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a25110:   Object 0xf6a25110:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a25120:   Object 0xf6a25120:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a25130:   Object 0xf6a25130:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a25140:   Object 0xf6a25140:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a25150:   Object 0xf6a25150:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a25160:   Object 0xf6a25160:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a25170:   Object 0xf6a25170:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a25180:   Object 0xf6a25180:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a25190:   Object 0xf6a25190:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkk=
kkkkk
 kkkkkkkkkkkkkkkk
  Object 0xf6a251a0:   Object 0xf6a251a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 a5 kkkkkkkkkkk=
kkkk=EF=BF=BD
 kkkkkkkkkkkkkkk=EF=BF=BD
 Redzone 0xf6a251b0:  Redzone 0xf6a251b0:  bb bb bb bb bb bb bb bb         =
                                                                =EF=BF=BD=
=EF=BF=BD=EF=BF=BD=EF=BF=BD           =20
 =EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD           =20
 Padding 0xf6a251d8:  Padding 0xf6a251d8:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a=
 5a 5a 5a 5a 5a                                                 ZZZZZZZZ   =
    =20
 ZZZZZZZZ       =20
Pid: 0, comm: swapper Not tainted 2.6.33-rc5-22551-g8914f8e #10
Pid: 0, comm: swapper Not tainted 2.6.33-rc5-22551-g8914f8e #10
Call Trace:
Call Trace:
 [<c10910d1>] ? check_bytes_and_report+0x7b/0x98
 [<c10910d1>] ? check_bytes_and_report+0x7b/0x98
 [<c1091192>] ? check_object+0xa4/0x187
 [<c1091192>] ? check_object+0xa4/0x187
 [<c1092572>] ? __slab_alloc+0x32f/0x3fb
 [<c1092572>] ? __slab_alloc+0x32f/0x3fb
 [<c10925ae>] ? __slab_alloc+0x36b/0x3fb
 [<c10925ae>] ? __slab_alloc+0x36b/0x3fb
 [<c1092e9a>] ? __kmalloc_track_caller+0xd6/0x13c
 [<c1092e9a>] ? __kmalloc_track_caller+0xd6/0x13c
 [<c12ec5cb>] ? __netdev_alloc_skb+0x14/0x2d
 [<c12ec5cb>] ? __netdev_alloc_skb+0x14/0x2d
 [<c12ec5cb>] ? __netdev_alloc_skb+0x14/0x2d
 [<c12ec5cb>] ? __netdev_alloc_skb+0x14/0x2d
 [<c12ec2e6>] ? __alloc_skb+0x4b/0x10c
 [<c12ec2e6>] ? __alloc_skb+0x4b/0x10c
 [<c12ec5cb>] ? __netdev_alloc_skb+0x14/0x2d
 [<c12ec5cb>] ? __netdev_alloc_skb+0x14/0x2d
 [<c124ae51>] ? tg3_alloc_rx_skb+0x92/0x151
 [<c124ae51>] ? tg3_alloc_rx_skb+0x92/0x151
 [<c124e9ac>] ? tg3_poll_work+0x39a/0x89b
 [<c124e9ac>] ? tg3_poll_work+0x39a/0x89b
 [<c124ef2d>] ? tg3_poll+0x80/0x17c
 [<c124ef2d>] ? tg3_poll+0x80/0x17c
 [<c12f4700>] ? net_rx_action+0x94/0x152
 [<c12f4700>] ? net_rx_action+0x94/0x152
 [<c102eaf0>] ? __do_softirq+0xaf/0x152
 [<c102eaf0>] ? __do_softirq+0xaf/0x152
 [<c102ebb6>] ? do_softirq+0x23/0x27
 [<c102ebb6>] ? do_softirq+0x23/0x27
 [<c100367c>] ? do_IRQ+0x7d/0x8e
 [<c100367c>] ? do_IRQ+0x7d/0x8e
 [<c1002bc9>] ? common_interrupt+0x29/0x30
 [<c1002bc9>] ? common_interrupt+0x29/0x30
 [<c1007cf2>] ? mwait_idle+0x76/0x7b
 [<c1007cf2>] ? mwait_idle+0x76/0x7b
 [<c10018da>] ? cpu_idle+0x37/0x4b
 [<c10018da>] ? cpu_idle+0x37/0x4b
FIX kmalloc-2048: Restoring 0xf6a24ca8-0xf6a24cab=3D0x6b
FIX kmalloc-2048: Restoring 0xf6a24ca8-0xf6a24cab=3D0x6b


FIX kmalloc-2048: Marking all objects used
FIX kmalloc-2048: Marking all objects used


--9amGYk9869ThD9tj
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--9amGYk9869ThD9tj--
