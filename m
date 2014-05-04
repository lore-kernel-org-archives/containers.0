From: Marian Marinov <mm-108MBtLGafw@public.gmane.org>
Subject: Re: [PATCH] IPC initialize shmmax and shmall from the current value
	not the default
Date: Sun, 04 May 2014 03:28:37 +0300
Message-ID: <536589B5.8060900@1h.com>
References: <5365723D.7030303@1h.com>
	<1399161216.2573.9.camel@buesod1.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1399161216.2573.9.camel-5JQ4ckphU/8SZAcGdq5asR6epYMZPwEe5NbjCUgZEJk@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Davidlohr Bueso <davidlohr-VXdhtT5mjnY@public.gmane.org>
Cc: manfred-nhLOkwUX5cPe2c5cEj3t2g@public.gmane.org, Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, n-horiguchi-PaJj6Psr51x8UrSeD/g0lQ@public.gmane.org
List-Id: containers.vger.kernel.org

On 05/04/2014 02:53 AM, Davidlohr Bueso wrote:
> On Sun, 2014-05-04 at 01:48 +0300, Marian Marinov wrote:
>> When we are creating new IPC namespace that should be cloned from the current namespace it is a good idea to copy the
>> values of the current shmmax and shmall to the new namespace.
>
> Why is this a good idea?
>
> This would break userspace that relies on the current behavior.
> Furthermore we've recently changed the default value of both these
> limits to be as large as you can get, thus deprecating them. I don't
> like the idea of this being replaced by namespaces.
>
> Thanks,
> Davidlohr
>

The current behavior is create_ipc_ns()->shm_init_ns()

void shm_init_ns(struct ipc_namespace *ns)
{
     ns->shm_ctlmax = SHMMAX;
     ns->shm_ctlall = SHMALL;
     ns->shm_ctlmni = SHMMNI;
     ns->shm_rmid_forced = 0;
     ns->shm_tot = 0;
     ipc_init_ids(&shm_ids(ns));
}

This means that whenever you are creating an IPC namespace it gets its SHMMAX and SHMALL values from the defaults for 
the kernel.
If for some reason you want to have smaller(or bigger, for older kernels) limit. This means changing the values in 
/proc/sys/kernel/shmmax and /proc/sys/kernel/shmall. However the program that is started with the new IPC namespace may 
lack privileges to write to these files and so it can not modify them.

What I'm proposing is simply to copy the current values of the host machine, as set by a privileged process before the 
namespace creation.

Maybe a better approach would be to allow the changes to be done by processes having CAP_SYS_RESOURCE inside the new 
namespace?

Marian

-- 
Marian Marinov
Founder & CEO of 1H Ltd.
Jabber/GTalk: hackman-/eSpBmjxGS4dnm+yROfE0A@public.gmane.org
ICQ: 7556201
Mobile: +359 886 660 270
