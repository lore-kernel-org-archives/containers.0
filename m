From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 0/9] OpenVZ kernel based checkpointing/restart
Date: Thu, 30 Oct 2008 10:03:35 -0700
Message-ID: <1225386215.12673.280.camel@nimitz>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<200810271707.13580.major@openvz.org>
	<4905D2AD.1070309@cs.columbia.edu>
	<200810300902.47067.major@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200810300902.47067.major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2008-10-30 at 10:02 +0400, Andrey Mirkin wrote:
> Anyway we should ask everyone what they think about user- and kernel- based 
> process creation.
> Dave, Serge, Cedric, Daniel, Louis what do you think about that?

My worry is where a single sys_restart() plus in-kernel process creation
takes us.

In practice, what do we do?  Do we single-thread the entire restore
process?  Or, do we do in-kernel process creation and have multiple
kernel threads trying to read out of different points in the checkpoint
file, trying to restore all their own states in parallel?  Does that
mean that we can't in practice restore from a fd like a pipe or a
network socket?

In the same way, if we *do* create the processes in userspace, how do we
do _that_?  Do we just fork() and sleep() until the kernel comes along
and blows our state away?  How does the kernel process doing the
restoring tell userspace how many things to fork?  How do we match these
new userspace processes up with the ones coming out of the checkpoint
process?

To me, it's just way too early to talk about this stuff.  Both
approaches have their issues, and I'm yet to see the differences
manifested in code so I can really sink my teeth into them

-- Dave
