From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 0/9] OpenVZ kernel based checkpointing/restart
Date: Thu, 30 Oct 2008 10:08:44 -0700
Message-ID: <1225386524.12673.284.camel__5897.47715644098$1225386686$gmane$org@nimitz>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<200810271707.13580.major@openvz.org>
	<4905D2AD.1070309@cs.columbia.edu>
	<200810300902.47067.major@openvz.org>
	<20081030114747.GL15171@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081030114747.GL15171-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Cc: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 2008-10-30 at 12:47 +0100, Louis Rilling wrote:
> 1) this prevents userspace from doing weird things, like changing the task tree
> and let the kernel detect it and deal with the mess this creates (think about
> two threads being restarted in separate processes that do not even share their
> parents). But one can argue that userspace can change the checkpoint image as
> well, so that the kernel must check for such weird things anyway.

To me, this is one of the strongest arguments out there for doing
restart as much as possible with existing user<->kernel APIs.  Having
the kernel detect and clean up userspace's messes is not going to work.
We might as well just do things in the kernel rather than do that.

What we *should* do is leverage all of the existing APIs that we already
have instead of creating completely new code paths into which my butter
fingers can introduce new kernel bugs.

> 2) restart will be more efficient with respect to shared objects.

Can you quantify this?  Which objects?  How much more efficient?

-- Dave
