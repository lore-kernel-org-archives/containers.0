From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: Network namespace and bonding WARNING at fs/proc/generic.c
	remove_proc_entry
Date: Thu, 5 Jul 2012 22:07:49 +0000
Message-ID: <20120705220749.GA11255@mail.hallyn.com>
References: <1340900320.3441.88.camel@pro6455b.example.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1340900320.3441.88.camel-1RhL1yiVGhRuYUHNOcvv81aTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dilip Daya <dilip.daya-VXdhtT5mjnY@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Dilip Daya (dilip.daya-VXdhtT5mjnY@public.gmane.org):
> Hi,
> 
> I'd discussed the following with Serge Hallyn.
> 
> => Environment based on 3.2.18 / x86_64 kernel.
> => WARNING: at fs/proc/generic.c:808 remove_proc_entry+0xdb/0x21f()
> => WARNING: at fs/proc/generic.c:849 remove_proc_entry+0x208/0x21f()

Hi,

thanks much for sending this.  I'm still getting this error on
3.5.0-2-generic (today's ubuntu quantal kernel)

> network namespace and bonding
> -----------------------------
> 
> * Migrate two phy nics from host to netns (netns0).
>   - ip link set ethX netns netns0
> 
> * In host environment:
>   - load bonding module, /sbin/modprobe -v bonding mode=1 miimon=100
>   - /sys/class/net/bond0 exists.
>   - /proc/net/bonding/bond0 exists.
>   - /sys/class/net/bonding_masters has bond0.
> 
> * Migrate bond0 to netns (netns0):
>   - ip link set bond0 netns netns0.
> 
> * Within netns (netns0):
>   - /sys/class/net/bonding_masters is empty.
>   - /sys/class/net/bond0 exist.
>   - configure bond0 and ifenslave with two phy nics.
>   - /proc/net/bonding/bond0 does not exist within netns0, but does
>     exist in the host environment.
>   - /sys/class/net/bonding_masters is empty.

mine is not empty, fwiw.  However

>   - ping to remote end of bond0 works.
> 
> * Within netns (netns0), flushing ethX and bondY:
>   - down bond0 and its phy nic interfaces:
>   - ip link set ... down
>   - ip addr flush dev [bond0 | eth#]
>   - deleting bond0, /sbin/ip link del dev bond0

Yup I still get a remove_proc_entry WARNING at fs/proc/generic.c:808,
which is the warning when (!de)

-serge
