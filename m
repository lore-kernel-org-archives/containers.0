From: anqin <anqin.qin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: No limitation in physical memory in cgroups
Date: Fri, 22 May 2009 17:25:12 +0800
Message-ID: <d95d44a20905220225t539b07edk31b61a8e7ffe1c1f@mail.gmail.com>
References: <d95d44a20905192252t6cce5169y730a37184075beb9@mail.gmail.com>
	<4A13ABC8.2000907@cn.fujitsu.com>
	<d95d44a20905200335v6aabfc28qa3958e8404965775@mail.gmail.com>
	<20090521085857.d4b82cba.kamezawa.hiroyu@jp.fujitsu.com>
	<d95d44a20905202347y177e9744k1a9817236a102b53@mail.gmail.com>
	<20090521161556.2eca8fd0.kamezawa.hiroyu@jp.fujitsu.com>
	<d95d44a20905210456q13b2334avecb0dc6ff0f0d26@mail.gmail.com>
	<20090521151848.GQ4858@balbir.in.ibm.com>
	<d95d44a20905211931v3918b5d3p79d47225963c81f3@mail.gmail.com>
	<20090522115622.30cb514a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090522115622.30cb514a.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

I have recompiled the kernel and tested again.
When I set the limitation of swap, the test program
is killed when it want to apply more memory.

Thanks.


>> hmm.... =A0I am not sure. I just compiled the kernel at default.
>> Where can I check the boot parameter? In /boot/grub/menu.list,
>> no the parameter yet.
>>
> Hmm. When
>
> CONFIG_CGROUP_MEM_RES_CTLR=3Dy
> CONFIG_CGROUP_MEM_RES_CTLR_SWAP=3Dy
>
> And no special boot option, the memory cgroup directory will be.
> =3D=3D
> [root@bluextal cgroup]# ls /cgroups/A/
> memory.failcnt =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memory.memsw.usage_in_=
bytes
> memory.force_empty =A0 =A0 =A0 =A0 =A0 =A0 =A0 memory.stat
> memory.limit_in_bytes =A0 =A0 =A0 =A0 =A0 =A0memory.swappiness
> memory.max_usage_in_bytes =A0 =A0 =A0 =A0memory.usage_in_bytes
> memory.memsw.failcnt =A0 =A0 =A0 =A0 =A0 =A0 memory.use_hierarchy
> memory.memsw.limit_in_bytes =A0 =A0 =A0notify_on_release
> memory.memsw.max_usage_in_bytes =A0tasks
> =3D=3D
>
> You can see memory.memsw.* for limiting mem+swap usage.
> This memory.memsw. files disappears when you set "noswapaccount" boot opt=
ion...
>
> I can only say "counld you confirm again ?"
> =A0config, the kernel version etc...
>
> Sorry for no help.
>
> Bye.
> -Kame
>
>
>
