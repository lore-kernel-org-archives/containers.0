From: Lord Glauber Costa of Sealand <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH review 3/6] userns: Recommend use of memory control groups.
Date: Mon, 28 Jan 2013 12:22:48 +0400
Message-ID: <51063558.1010402@parallels.com>
References: <87ehh8it9s.fsf@xmission.com> <87txq4hedl.fsf@xmission.com>
	<51062AB5.9060203@parallels.com>
	<51062DA8.1060804@parallels.com> <87k3qxu3kp.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87k3qxu3kp.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 01/28/2013 12:14 PM, Eric W. Biederman wrote:
> Lord Glauber Costa of Sealand <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:
> 
>> I just saw in a later patch of yours that your concern here seems not
>> limited to backed ram by tmpfs, but with things like the internal
>> structures for userns , to avoid patterns in the form: 'for (;;)
>> unshare(...)'
>>
>> Humm, it does seem sensible. The kernel memory controller aims to
>> prevent exactly things like that. But they all exist already before
>> userns: there are destructive patterns like that with sockets, dentries,
>> processes, and pretty much every other resource in the kernel. So
>> Although the recommendation per-se makes sense, I am wondering if it is
>> worth it to mention anything in the user_ns config?
> 
> The config might be overkill.  However I have already gotten bug reports
> about there being no limits.
> 
> So someone needs to stop and connect the dots and say: 
Absolutely, and I am all for it

> "If you care this is what you can do." 

How about we say it, then?

The current text in quite cryptic in this aspect, in the sense that it
doesn't give enough information for standard people about what are the
problems involved.

Of course, maybe the Kconfig text is not the best place for having all
the info: but don't we have some place in Documentation/ where we could
put this, and then refer people there from Kconfig ?
