From: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: call_usermodehelper in containers
Date: Thu, 18 Feb 2016 12:43:31 +0900
Message-ID: <56C53DE3.1070108@jp.fujitsu.com>
References: <20131111071825.62da01d1@tlielax.poochiereds.net>
	<20131112004703.GB15377@kroah.com>
	<20131112061201.04cf25ab@tlielax.poochiereds.net>
	<528226EC.4050701@parallels.com>
	<20131112083043.0ab78e67@tlielax.poochiereds.net>
	<5285FA0A.2080802@parallels.com> <871u2incyo.fsf@xmission.com>
	<20131118172844.GA10005@redhat.com>
	<1455149857.2903.9.camel@themaw.net>
	<8737sq4teb.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8737sq4teb.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Ian Kent <raven-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org>
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On 2016/02/18 11:57, Eric W. Biederman wrote:
> 
> Ccing The containers list because a related discussion is happening there
> and somehow this thread has never made it there.
> 
> Ian Kent <raven-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org> writes:
> 
>> On Mon, 2013-11-18 at 18:28 +0100, Oleg Nesterov wrote:
>>> On 11/15, Eric W. Biederman wrote:
>>>>
>>>> I don't understand that one.  Having a preforked thread with the
>>>> proper
>>>> environment that can act like kthreadd in terms of spawning user
>>>> mode
>>>> helpers works and is simple.
>>
>> Forgive me replying to such an old thread but ...
>>
>> After realizing workqueues can't be used to pre-create threads to run
>> usermode helpers I've returned to look at this.
> 
> If someone can wind up with a good implementation I will be happy.
> 
>>> Can't we ask ->child_reaper to create the non-daemonized kernel thread
>>> with the "right" ->nsproxy, ->fs, etc?
>>
>> Eric, do you think this approach would be sufficient too?
>>
>> Probably wouldn't be quite right for user namespaces but should provide
>> what's needed for other cases?
>>
>> It certainly has the advantage of not having to maintain a plague of
>> processes waiting around to execute helpers.
> 
> That certainly sounds attractive.  Especially for the case of everyone
> who wants to set a core pattern in a container.
> 
> I am fuzzy on all of the details right now, but what I do remember is
> that in the kernel the user mode helper concepts when they attempted to
> scrub a processes environment were quite error prone until we managed to
> get kthreadd(pid 2) on the scene which always had a clean environment.
> 
> If we are going to tie this kind of thing to the pid namespace I
> recommend simplying denying it if you are in a user namespace without
> an approrpriate pid namespace.  AKA simply not allowing thigns to be setup
> if current->pid_ns->user_ns != current->user_ns.
> 
Can't be handled by simple capability like CAP_SYS_USERMODEHELPER ?

User_ns check seems not to allow core-dump-cather in host will not work if user_ns is used.

Thanks,
-Kame
