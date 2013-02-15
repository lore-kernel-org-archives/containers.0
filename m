From: Corey Minyard <tcminyard-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] Move console redirect to pid namespace
Date: Fri, 15 Feb 2013 08:50:26 -0600
Message-ID: <511E4B32.3030003@acm.org>
References: <1360376920-30824-1-git-send-email-minyard@acm.org>
	<20130209191409.643c3d7f@neptune.home>
	<87r4kkuj4o.fsf@xmission.com> <511D9890.1040900@acm.org>
	<87d2w29pdo.fsf@xmission.com>
Reply-To: minyard-HInyCGIudOg@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87d2w29pdo.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Corey Minyard <cminyard-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>, =?UTF-8?B?QnJ1bm8gUHLDqW1vbnQ=?= <bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 02/14/2013 10:23 PM, Eric W. Biederman wrote:
>
>>> With recent changes this is tied to the initial user namespace.  So the
>>> simple solution to this and so many other similiar security problems is
>>> to run your container in a user namespace.
>>>
>>> The permission check currently is capable(CAP_SYS_ADMIN) which requires
>>> the caller to have the CAP_SYS_ADMIN in the initial user namespace.
>> I'm not sure I follow.  Are these changes in k.org, or in another
>> repository someplace?
> In k.org. 3.7 would work. 3.8-rcX would work even better.
>
> root in a user namespace does not have permission to call TIOCCONS.

Ok, that's good enough for me.  I don't have a compelling reason to make 
it work, beyond liking consistency.

Thank you,

-corey
