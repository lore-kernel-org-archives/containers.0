From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Getting userns enabled in vendor kernels
Date: Fri, 15 Nov 2013 00:52:14 -0800
Message-ID: <87ob5moxmp.fsf@xmission.com>
References: <20131113151330.GZ32643@redhat.com>
	<5285AEF1.6000503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5285AEF1.6000503-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> (Gao feng's message of "Fri, 15
	Nov 2013 13:19:45 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:

> On 11/13/2013 11:13 PM, Daniel P. Berrange wrote:
>> 
>>   commit 5eaf563e53294d6696e651466697eb9d491f3946
>>   Author: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>>   Date:   Mon Nov 21 17:22:31 2011 -0800
>> 
>>     userns: Allow unprivileged users to create user namespaces.
>
> I don't know what's the benefit this commit brings and what's use
> case this commit tries to support.
>
> In most use case, the container/namespace is create by privilged
> user and the id-map can prevent unsafe things.
>
> IMO, I think this patch can be reverted.

This patch brings tremendous benefit, and by itself is completely safe.

It is the added ns_capable calls that are potentially dangerous, and it
seems you like the idea of taking advantage of those.

The goal is to not let anything that is not safe for an unprivileged
user to use happen in a user namespace.  One primary use for user
namespaces is separate administrative domains.  Aka allowing someone you
don't trust with root privileges to do things on your box.  You trust
them with shell access but that is another story.

So if it is safe enough in general for people with shell access to use
the functionality.  Restricting the creation of user namespaces to root
is silly.

Restricting user namespaces creation to root really is a form of
sticking your fingers in your, closesing your eyes, and going
la-la-la-la I can't hear you.  When faced with security issues.

For production use it is either as safe as the rest of the kernel or it
is not.  A sysctl so you can turn user namespaces on/off so you can
experiment with them while they are maturing is something that might be
reasonable.  But again that is another form of CYA.  But a likely a
reasonable CYA for a distroy kernel.

I intend to fix bugs and enable people to actually use their kernel not
run around and trying and point the blame for things that go wrong at
others.

And now back to my regularly scheduled bug fixing.

Eric
