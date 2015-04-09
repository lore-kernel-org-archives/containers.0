From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review  4/4] vfs: Do not allow escaping from bind mounts.
Date: Thu, 09 Apr 2015 11:52:15 -0500
Message-ID: <87oamx6y80.fsf@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<87iod68aa3.fsf_-_@x220.int.ebiederm.org>
	<20150409130601.GA22250@pc.thejh.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150409130601.GA22250-J1fxOzX/cBvk1uMJSBkQmQ@public.gmane.org> (Jann Horn's message of
	"Thu, 9 Apr 2015 15:06:01 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org> writes:

> On Wed, Apr 08, 2015 at 06:34:12PM -0500, Eric W. Biederman wrote:
>> +static unsigned d_depth(const struct dentry *dentry)
>> +{
>> +	unsigned depth = 0;
>> +
>> +	while (!IS_ROOT(dentry)) {
>> +		dentry = dentry->d_parent;
>> +		depth++;
>> +	}
>> +	return depth;
>> +}
>
> This relies on a depth of 2^32 being impossible, right? Which is guaranteed
> somewhat because you would need something like a terabyte of RAM to have
> that many dentries in RAM? I can't find any explicit check. Maybe it would
> make sense to let the depth be 64 bits or add some kind of overflow check?
> Or did I just miss some kind of check on allocation?

Well there is the 4K PATH_MAX.

If nothing else your performance will grind to a halt if you attempt to
use a path that deeply nested.

That said it doesn't cost us anything to make the variables
unsigned long and it avoids having to worry about this piece of code.

I will respin this patch.

Eric
