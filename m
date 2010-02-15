From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 1/1] RFC: taking a crack at targeted capabilities
Date: Mon, 15 Feb 2010 08:48:14 -0800
Message-ID: <m1r5oma1ip.fsf@fess.ebiederm.org>
References: <20100106062809.GA17064@us.ibm.com>
	<m17hrv18ad.fsf@fess.ebiederm.org> <20100106201725.GA24242@us.ibm.com>
	<20100215142746.GD3714@count0.beaverton.ibm.com>
	<m13a12bhjq.fsf@fess.ebiederm.org>
	<20100215163708.GG3714@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100215163708.GG3714-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org> (Matt Helsley's
	message of "Mon\, 15 Feb 2010 08\:37\:08 -0800")
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

>> > The other example of that idea was keeping a syslog_ns reference in
>> > the netns for the iptables printks in ipt_LOG.c. What happens when
>> > one of the CONFIG_*NS options isn't selected? Suddenly we're littering
>> > the struct definitions with #ifdefs and making the code alot more
>> > complicated to test (I suspect). Perhaps it's time to merge all
>> > the CONFIG_*NS options into CONFIG_NAMESPACES?

In general the plan has been to support disabling the creation of namespaces
but that is about it.  The disables are there to prevent sysadmins from
dealing with under-construction code, as in general we can not remove the code
without having lots of weird paths.

Distro's will enable these, and the incremental cost of having the enabled
is small, at least if they are built properly.  If the incremental cost
of enabling a namespace is not small we probably need to go back to the
drawing board because maintainability will be affected.

Eric
