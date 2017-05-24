From: Ian Kent <raven-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org>
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
Date: Wed, 24 May 2017 17:16:49 +0800
Message-ID: <1495617409.2538.1.camel__24775.2154282809$1495617427$gmane$org@themaw.net>
References: <1495554267.27369.9.camel@HansenPartnership.com>
	<87zie3mxkc.fsf@xmission.com>
	<f167feeb-e653-12e3-eec8-24162f7f7c07@suse.de>
	<149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
	<1495472039.2757.19.camel@HansenPartnership.com>
	<2446.1495551216@warthog.procyon.org.uk>
	<2961.1495552481@warthog.procyon.org.uk> <87bmqjmwl5.fsf@xmission.com>
	<3860.1495557363@warthog.procyon.org.uk> <87k256ek3e.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87k256ek3e.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2017-05-24 at 03:26 -0500, Eric W. Biederman wrote:
> 
> So far no one has even bothered to seriously try the one solution that
> is guaranteed to work because it takes a lot of changes to kernel code.
> I believe the last effort snagged on what a pain it is to refactor the
> user mode helper infrastructure.

Yes, that's mostly true in my case although I wouldn't say I haven't looked at
it seriously but equally I haven't got anything towards it yet either, sorry.

I'm likely going to revisit this based on a couple of approaches.

One is just what you describe and I had already been looking at this some time
ago. It seems to me that adding a work queue type that starts and retains a
process until the work queue is destroyed (similar to the way the work queue sub
system starts a fail over thread for use under resource exhaustion) would be a
sensible way to do it.

This doesn't mean I think it's a good idea for reasons I've outlined in the past
but the approach does warrant the effort to work out if it can be used without
problems.

And there's also the request key infrastructure which, as it is now, gets in the
road of verifying results, *sigh*.

Ian
