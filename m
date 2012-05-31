From: Jeff Liu <jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 10/12] container quota: bill container inodes alloc/free
	on ext4.
Date: Thu, 31 May 2012 09:43:18 +0800
Message-ID: <4FC6CCB6.4090908@oracle.com>
References: <1338389946-13711-1-git-send-email-jeff.liu@oracle.com>
	<1338389946-13711-11-git-send-email-jeff.liu@oracle.com>
	<20120530155543.GB13236@thunk.org>
Reply-To: jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120530155543.GB13236-AKGzg7BKzIDYtjvyW6yDsg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ted Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Cc: jack-AlSwsSmVLrQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, bpm-sJ/iWh9BUns@public.gmane.org, christopher.jones-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tm-d1IQDZat3X0@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, tinguely-sJ/iWh9BUns@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Ted,

Thanks for your response!
On 05/30/2012 11:55 PM, Ted Ts'o wrote:

> On Wed, May 30, 2012 at 10:59:04PM +0800, jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org wrote:
>>  	dquot_free_inode(inode);
>> +	ns_dquot_free_inode(inode);
> 
> It looks like you are adding ns_dquot_<foo>() with exactly the same
> arguments after dquot_<foo>() calls, for various values of <foo>.
> 
> Instead of needing to change all of the file systems, would it be
> possible simply to change the quota layer to call the ns_dquot_*
> functions?

I also think that is stupid to change all of the file systems with those
hook routines.
At first I have tried to change the quota layer by adding
ns_dquot_<foo>() to the corresponding dquot_<foo>(), it could works on
ext4, and it should works on other file systems which are tightly bound
to VFS quota IMHO.

However, XFS has its own quota management subsystem, with looser binding
to VFS quota.  That's why am trying to export those routines over all
the file systems and CC to the maintainers, sorry for the noise.

Nevertheless, I will try to find out a straightforward way according to
your comments.

Thanks,
-Jeff

> It might make your life simpler, and it would certainly
> reduce the number of filesystem maintainers that would need to look
> through and review your changes.  You'd just have to work with Jan
> Kara as the quota system maintainer.


> 
> Regards,
> 
> 						- Ted
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ext4" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
