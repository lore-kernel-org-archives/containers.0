From: Jeff Liu <jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: container disk quota
Date: Sat, 02 Jun 2012 13:42:18 +0800
Message-ID: <4FC9A7BA.5020805@oracle.com>
References: <1338389946-13711-1-git-send-email-jeff.liu@oracle.com>
	<20120601155457.GA30909@quack.suse.cz>
Reply-To: jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120601155457.GA30909-+0h/O2h83AeN3ZZ/Hiejyg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Cc: tytso-3s7WtUTddSA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, bpm-sJ/iWh9BUns@public.gmane.org, christopher.jones-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tm-d1IQDZat3X0@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, tinguely-sJ/iWh9BUns@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Jan,

On 06/01/2012 11:54 PM, Jan Kara wrote:

>   Hello,
> 
> On Wed 30-05-12 22:58:54, jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org wrote:
>> According to glauber's comments regarding container disk quota, it should be binded to mount
>> namespace rather than cgroup.
>>
>> Per my try out, it works just fine by combining with userland quota utilitly in this way.
>> However, they are something has to be done at user tools too IMHO.
>>
>> Currently, the patchset is in very initial phase, I'd like to post it early to seek more
>> feedbacks from you guys.
>>
>> Hopefully I can clarify my ideas clearly.
>   So what I miss in this introductory email is some highlevel description
> like what is the desired functionality you try to implement and what is it
> good for. Looking at the examples below, it seems you want to be able to
> set quota limits for namespace-uid (and also namespace-gid???) pairs, am I
> right?

Sorry for lacking the high level descriptions.

The main idea is to introduce a quota mechanism to let container make use of it like VFS quota/quota
tools as transparent as possible.

However our general quota subsystem works with one global hashtable list, and it based on superblock
and global UID/PID for those accounting, and looks that's not convenient to support container quota
without much changes IMHO.

The current opinion is to bind it to mount namespace, since container can be setup through CLONE_MNTNS to
have its private mount tree.

> 
>   If yes, then I would like to understand one thing: When writing to a
> file, used space is accounted to the owner of the file. Now how do we
> determine owning namespace?

That's also the main point I am concerned.
It think the latest USER_NS feature would be got involved in.
And also, we can detect the mount namespace by inferring it from processes context.  We only bill those
space operations if themount namespace is quota desired.

Here has another issue, when we doing quota info initialization on a mount namespace?
In my current implementation, it is simply implemented by checking if mount namespace was cloned out,
and do quotactl(2) if the input device is "rootfs",  or just checking if the mount namespace is not the
initial global one.
quotactl(2) will be processed if meet either above conditions, and space operations will be counted if
the desired UID/GID dquot could be searched.

> Do you implicitely assume that only processes
> from one namespace will be able to access the file?

All processes could access the file, but only those space operation of processes resides in the mount
namespace with quota setup will be billed.


Thanks,
-Jeff

> 								Honza
