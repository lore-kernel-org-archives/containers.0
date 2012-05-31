From: Ted Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Subject: Re: [PATCH 10/12] container quota: bill container inodes
	alloc/free on ext4.
Date: Wed, 30 May 2012 21:54:53 -0400
Message-ID: <20120531015453.GA6759@thunk.org>
References: <1338389946-13711-1-git-send-email-jeff.liu@oracle.com>
	<1338389946-13711-11-git-send-email-jeff.liu@oracle.com>
	<20120530155543.GB13236@thunk.org> <4FC6CCB6.4090908@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4FC6CCB6.4090908-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jeff Liu <jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: jack-AlSwsSmVLrQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, bpm-sJ/iWh9BUns@public.gmane.org, christopher.jones-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tm-d1IQDZat3X0@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, tinguely-sJ/iWh9BUns@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, May 31, 2012 at 09:43:18AM +0800, Jeff Liu wrote:
> I also think that is stupid to change all of the file systems with those
> hook routines.
> At first I have tried to change the quota layer by adding
> ns_dquot_<foo>() to the corresponding dquot_<foo>(), it could works on
> ext4, and it should works on other file systems which are tightly bound
> to VFS quota IMHO.
> 
> However, XFS has its own quota management subsystem, with looser binding
> to VFS quota.  That's why am trying to export those routines over all
> the file systems and CC to the maintainers, sorry for the noise.

No worries about the noise.  I was just trying to suggest something
that might be easier for you.

As near as I can tell XFS doesn't use the fs/quota functions at all,
yes?  But if you add it into the fs/quota functions, it should get you
integration with ext2, ext3, ext4, jfs, ocfs2, and reiserfs.  Yes?

	    	       	     	   	       - Ted
