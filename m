From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Virtualizing /proc/sys/kernel/random/boot_id per container ?
Date: Tue, 04 Sep 2012 02:20:46 -0700
Message-ID: <878vcq5ekx.fsf@xmission.com>
References: <20120830211832.GA3297@redhat.com> <878vcwjabu.fsf@xmission.com>
	<20120830225002.GA9226@redhat.com> <87bohrhqai.fsf@xmission.com>
	<5044629C.3030909@parallels.com> <87r4qi6g6k.fsf@xmission.com>
	<5045BF05.9050707@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5045BF05.9050707-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> (Glauber Costa's message of
	"Tue, 4 Sep 2012 12:42:45 +0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:
>> The twist of course is what does a boot mean.  If we are really after
>> machine boots than the current behavior is correct.
>> 
>> Looking back in the archives the desired behavior appears to be a value
>> that can be used to see if a pid value must be stale.
>> 
>> As a stale pid detector boot_id is pretty lousy.  Pids can still be
>> reused.
>> 
>> Still a role as a stale pid detector makes it clear which namespace
>> boot_id should be in and how we should treat boot_id upon migration.
>> 
>> You can only serve as a stale pid detector if you are in the pid
>> namespace.
>> 
>> So at this point patches are welcome.  Hopefully with a summary
>> of the discussion.
>> 
>> Eric
>> 
>
> Your discussion about boot_id being a limited solution is totally valid.
> But it is orthogonal to the question of whether or not a container
> should have it.

The important part is that boot_id as originally conceived is an
identifier to be used in conjunction with pids.  Therefore boot_id is a
proper pid_namespace component, and there are no semantic problems with
putting it in the kernel.

> I took a look at this, and I think the kernel should be in perfect
> position to do it.

Agreed.

> boot_id as a pid namespace id is a very well defined concept.

Agreed.

A reference to the history and the definition needs to be in the patch
description.

> We just
> need an interface to set it up to make it stable across migration. Maybe
> we can accept writes to this file as valid, provided the pid namespace
> has only the init process.

I think the easy solution is to take advantage of the fact that boot_id
is initialized lazily.  Don't allow writes if boot_id has already been
read.

> Then any tool could clone, mount proc, set this id, and continue
> normally. Any objections ?

My biggest concern is that creating multiple pid namespaces might allow
a way to drain the entropy pool in a way that we don't allow normal
users.

This is important to look at as with a little luck we will have
unprivileged creation of user namespaces and pid namespaces in the near
future.

Eric
