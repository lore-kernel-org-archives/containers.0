From: Enrico Weigelt <lkml-EcKl7qYKIbxeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH] p9caps: add Plan9 capability devices
Date: Wed, 14 Feb 2018 18:58:00 +0100
Message-ID: <23e3c1de-13e0-34ab-e2a8-b40c59e5b986__1550.18209848112$1518631012$gmane$org@metux.net>
References: <40d4c871-a16a-7b8f-2d4a-422a5a490693@infradead.org>
	<20180211215028.16210-1-metux@gmx.de>
	<20180211215028.16210-2-metux@gmx.de>
	<20180213071655.GA11240@mail.hallyn.com>
	<3a99edaf-0365-ec7e-4d2f-1e21dea007ac@gmx.de>
	<20180214145650.GA2102@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180214145650.GA2102-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, "Enrico Weigelt, metux IT consult" <metux-Mmb7MZpHnFY@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 14.02.2018 15:56, Serge E. Hallyn wrote:

> If it's an out of tree module you'd have to do it this way, but if > it's in-tree, even as a module, adding a bit to the userns struct> 
would imo be ok.
Assuming one doesn't try to load the module when the kernel image
previously was built w/o it ;-) (well, could export some dummy
symbol for protection ;-)).

OTOH, that raises the question, where / how exactly the cap list
destruction / expiry should be done. My original plan was adding
a timer in the p9caps module that just scans for old entries.

Should the userns code just call back on userns destruction ?
(in that case it would be tricky to have it as a module)

>> the whole thing might become a bit more complex when introducing
>> plan9-like unprivileged mount operations. haven't sorted out how to
>> do that yet.
> 
> I hope you'll have a discussion here about that first.

Yes, of course - that's why I'm here :p

My current idea is introducing some special flag for disabling suid
completely and switch into an private namespace, where now the
unprivileged user can mount at will and create new mnt namespaces,
just like on Plan9.

I'll try some qnd hacks w/ a new syscall, lets see where it leads to,
and then sort out how to do that in a more appropriate way.

> Now speaking practically, I love the caphash idea, but it does
> have issues with a modern login system.  There are privileged
> things which login needs to do besides changing uid, including but
> not limited to:
> 1. setting limits
> 2. setting loginuid,
> 3. mounting things (polyinstantiated /tmp, decrypted homedir, etc)
> 4. setting selinux context

For now, I don't think that's necessary for doing things the Plan9 way.
Perhaps we later could extend the /dev/caphash interface w/ additional
parameters for that.

> (and of course gplv3 as Al pointed out is a blocker)

already fixed.


--mtx

-- 
Enrico Weigelt, metux IT consult
Free software and Linux embedded engineering
info-EcKl7qYKIbxeoWH0uzbU5w@public.gmane.org -- +49-151-27565287
