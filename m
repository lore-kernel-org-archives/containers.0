From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 0/2 v2] userns: show current values of user namespace
	counters
Date: Mon, 10 Oct 2016 15:44:09 -0500
Message-ID: <871szo53za.fsf@x220.int.ebiederm.org>
References: <1471291822-539-1-git-send-email-avagin@openvz.org>
	<20161006175146.GA25935@outlook.office365.com>
	<87wphlclwe.fsf@x220.int.ebiederm.org>
	<20161010162202.GA31628@outlook.office365.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20161010162202.GA31628-1ViLX0X+lBJGNQ1M2rI3KwRV3xvJKrda@public.gmane.org> (Andrei Vagin's
	message of "Mon, 10 Oct 2016 09:22:03 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Cc: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org> writes:

> On Thu, Oct 06, 2016 at 02:33:53PM -0500, Eric W. Biederman wrote:
>> Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org> writes:
>> 
>> > Hello Eric,
>> >
>> > What do you think about this series? It should be useful to know current
>> > usage for user counters.
>> 
>> I am in favor of knowing the values.  Unless there is a good reason not
>> to we should export the values with a read-only sysctl.  I believe that
>> is what other similar limits do.
>
> I want to have a place where I will be able to get limits for all
> users. I can't imagine how to do this with a sysctl. It will looks like
> multiline sysct-s, what doesn't look good. I will think. If you will
> have any ideas let me know. Thanks.

Something that has been on my wish list for a while has been to modify
/proc/sys/... to also show up under /proc/<pid>/sys/... for the
non-global values.  Now it might make sense to show these things in an
alternate filesystem.

At the same time I am a little leary of the desire.  Changing these
limits and watching them in a per-process / per-user sense is fine.
However their fundamental purpose is to be set and forget limits and
that only rarely should anyone need to mess with.  Which makes the
primary purpose of looking at them debugging and verifying that the
limits are set to reasonable values.

Active management if someone wants to go there is possible but it will
never be the primary purpose of these limits.

>> As for having per process knowledge I think that is probably something
>> we want to solve for these sysctls as well.
>> 
>> I don't think I saw anyone looking at this code from the perspective of
>> information leaks.  I think we need to ask that question, as similar
>> interfaces have been problematic from an information leak point of view.
>
> It's a good question.

I expect that we don't actually care.  The kernel tends to leak a lot of
this kind of information.  But I figure we should at least be able to
say we thought about it and we don't care.

Eric
