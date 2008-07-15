From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Feeding containers patches into linux-next
Date: Tue, 15 Jul 2008 10:50:14 -0700
Message-ID: <m1d4lff355.fsf@frodo.ebiederm.org>
References: <1216133004.8856.53.camel@nimitz>
	<20080715152933.GA12061@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080715152933.GA12061-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Tue, 15 Jul 2008 10:29:33 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
>> We've been basically merging containers patches through Andrew and -mm
>> for a while now.  It seems that some of the testing is starting to move
>> toward linux-next.
>> 
>> Has anyone considered what it would take for us to get a tree pulled
>> into there?  
>
> I'd guess we would need to:
>
> 	1. Beg Stephen :)
> 	2. Work with the lkml community to decide which patches are
> 	   sufficiently agreed-upon at least in principle to go into
> 	   linux-next.  I really think Eric's netns/sysfs patchset
> 	   belongs there.  I'd also like to see the freezer container
> 	   patchset.
> 	3. Pick someone to be maintain that tree.  Ideally someone
> 	   whom everyone here can agree upon.

I think Andrew said he intends to get most of -mm into linux-next
as soon in the next release cycle.  So this may not be a long term
problem.

The classic challenge is that we really need most of the patches to go
through other maintainers because they are not for subsystems we
maintain.  So I am fairly certain things like our network namespace
work will show up in linux-next because they show up in net-next-2.6.

Eric
