From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 04/11] Add backend support for suboridnate uids and gids
Date: Thu, 24 Jan 2013 14:59:31 -0800
Message-ID: <87ham6xk4s.fsf@xmission.com>
References: <87d2wxshu0.fsf@xmission.com> <87liblr344.fsf@xmission.com>
	<20130123182206.GA4468@mail.hallyn.com> <87a9ryyzh2.fsf@xmission.com>
	<20130124225008.GA3816@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130124225008.GA3816@sergelap> (Serge Hallyn's message of "Thu,
	24 Jan 2013 16:50:08 -0600")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, "Michael Kerrisk
	(man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nicolas =?utf-8?Q?Fran=C3=A7ois?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:

> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> In practice it doesn't matter but it looks worth fixing for the sake of
>> long term maintenance.
>
> I figured the users must all be ok, and in practice it would work out,
> but the fact remains subsequent function calls assigning to local stack
> can overwrite what you've returned.  <shrug>

Yes.  Once I make rangebuf static then subordinate_parse is ok (at least
interface wise).  But the bug is real and I will get out an incremental
patch shortly.

The subordinate_parse really isn't ok as I claimed a minute ago I had
overlooked I copied everything into the local variable rangebuf before
processing.  In practice it works of course but that is luck.

> The rest of what I've looked over looked ok, thanks much!

Welcome.

Do you think you can start getting this into Ubuntu?

Eric
