From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: uts: don't pass an unsigned var as a signed int
Date: Wed, 24 Jun 2009 13:07:27 -0400
Message-ID: <4A425D4F.2010103@cs.columbia.edu>
References: <20090619203719.GA30093@us.ibm.com>
	<m3prczfs2m.fsf@pobox.com>	<20090621001837.GA32394@hallyn.com>
	<m34ouaf942.fsf@pobox.com>	<20090621191305.GA2499@hallyn.com>
	<m3fxdsc3dm.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m3fxdsc3dm.fsf-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org



Nathan Lynch wrote:

[...]

> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

[...]

>> Oren,
>>
>> would it be possible to put up a filter, either manual or
>> automatic, to send every patch that gets pushed on the current
>> ckpt git branch to the containers list, maybe with a [CKPT PUSH]
>> tag in the subject line?
> 
> Or just post patches to the mailing list before committing them to
> public branches on which others are basing work.
> 
> This seems like an opportune moment to point out the guidelines for
> including a tree in linux-next:
> 
> all patches/commits in the tree/series must have been:
> 
> 	posted to a relevant mailing list
> 	reviewed
> 	unit tested
> 	destined for the next merge window (or the current release)
> 
> *before* they are included.
> 
> (source: http://lkml.org/lkml/2009/6/20/6 )
> 
> If upstream inclusion is the ultimate goal, those are the standards
> which apply.
> 
> 
>> I think it will foster much more review of every patch.  Right now
>> it feels like we just catch blatant bugs when they bite us too hard,
>> but I don't think many people are looking through 'git wc' every
>> day.

Yes, I agree with both suggestions, and will do both.

FWIW, I decided to push less-tested code to avoid delay for a long
period due to travel plans. Posting them on the list would have
helped to improve them, of course.

Oren.
