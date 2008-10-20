From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 0/9] OpenVZ kernel based checkpointing/restart
Date: Mon, 20 Oct 2008 16:14:35 +0400
Message-ID: <200810201614.36911.major__1998.45141401074$1224522620$gmane$org@openvz.org>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<1224286383.1848.65.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1224286383.1848.65.camel@nimitz>
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
To: devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Saturday 18 October 2008 03:33 Dave Hansen wrote:
> On Wed, 2008-09-03 at 14:57 +0400, Andrey Mirkin wrote:
> > This patchset introduces kernel based checkpointing/restart as it is
> > implemented in OpenVZ project. This patchset has limited functionality
> > and are able to checkpoint/restart only single process. Recently Oren
> > Laaden sent another kernel based implementation of checkpoint/restart.
> > The main differences between this patchset and Oren's patchset are:
>
> Hi Andrey,
>
> I'm curious what you want to happen with this patch set.  Is there
> something specific in Oren's set that deficient which you need
> implemented?  Are there some technical reasons you prefer this code?

Hi Dave,

Right now my patchset (v2) provides an ability to checkpoint and restart a 
group of processes. The process of checkpointing and restart can be initiated 
from external process (not from the process which should be checkpointed).
Also I think that all the restart job (including process forking) should be 
done in kernel, as in this case we will not depend on user space and will be 
more secure. This is also implemented in my patchset.

Andrey
