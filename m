From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 11/11] mnt: Honor MNT_LOCKED when detaching mounts
Date: Fri, 16 Jan 2015 12:29:39 -0600
Message-ID: <87vbk6zii4.fsf__20352.5355704643$1421433165$gmane$org@x220.int.ebiederm.org>
References: <1420490787-14387-11-git-send-email-ebiederm@xmission.com>
	<20150107184334.GZ22149@ZenIV.linux.org.uk>
	<87h9w2gzht.fsf@x220.int.ebiederm.org>
	<20150107205239.GB22149@ZenIV.linux.org.uk>
	<87iogi8dka.fsf@x220.int.ebiederm.org>
	<20150108002227.GC22149@ZenIV.linux.org.uk>
	<20150108223212.GF22149@ZenIV.linux.org.uk>
	<20150109203126.GI22149@ZenIV.linux.org.uk>
	<87h9vzryio.fsf@x220.int.ebiederm.org>
	<20150110055148.GY22149@ZenIV.linux.org.uk>
	<20150111020030.GF22149@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150111020030.GF22149-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> (Al Viro's message of
	"Sun, 11 Jan 2015 02:00:30 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> writes:

> On Sat, Jan 10, 2015 at 05:51:48AM +0000, Al Viro wrote:
>> On Fri, Jan 09, 2015 at 11:32:47PM -0600, Eric W. Biederman wrote:
>> 
>> > I don't believe rcu anything in this function itself buys you anything,
>> > but structuring this primitive so that it can be called from an rcu list
>> > traversal seems interesting.  
>> 
>> ???
>> 
>> Without RCU, what would prevent it being freed right under us?
>> 
>> The whole point is to avoid pinning it down - as it is, we can have
>> several processes call ->kill() on the same object.  The first one
>> would end up doing cleanup, the rest would wait *without* *affecting*
>> *fs_pin* *lifetime*.
>> 
>> Note that I'm using autoremove there for wait.func(), then in the wait
>> loop I check (without locks) wait.task_list being empty.  It is racy;
>> deliberately so.  All I really care about in there is checking that
>> wait.func has not been called until after rcu_read_lock().  If that is
>> true, we know that p->wait hadn't been woken until that point, i.e.
>> p hadn't reached rcu delay on the way to being freed until after our
>> rcu_read_lock().  Ergo, it can't get freed until we do rcu_read_unlock()
>> and we can safely take p->wait.lock.
>> 
>> RCU is very much relevant there.
>
> FWIW, I've just pushed a completely untested tree in #experimental-fs_pin;
> it definitely will be reordered, etc., probably with quite a few of the
> patches from the beginning of your series mixed in, but the current tree
> in there should show at least what I'm aiming at.

I have merged the work you have been doing and what I have been doing
and posted it to a branch #for-testing of my user-namespace.git tree.

And yes I managed to make the core of the pin primitive not care about
rcu, and I think I will need that property to clean up some of the
weirdness that I still see with using fs_pin.

pin_insert does not wind up being a clean primitive, adding to both
lists at the same time does not end up with particularly clean or
obvious locking rules or a clean locking impelementation.  

Still the code works and is a good starting point for further discussion
and thinking.  I am posting the code while I go off to see if I can spot
better ways to clean some of these things up.

Eric
