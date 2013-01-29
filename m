From: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH 00/11] pkg-shadow support subordinate ids with user
	namespaces
Date: Tue, 29 Jan 2013 12:15:37 -0600
Message-ID: <1359483337.32505.57@driftwood>
References: <87d2wxshu0.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="Flowed"; DelSp="Yes"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87d2wxshu0.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (from ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org on
	Tue Jan 22 03:11:19 2013)
Content-Disposition: inline
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nicolas =?iso-8859-1?q?Fran=E7ois?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>
List-Id: containers.vger.kernel.org

I am waaaay behind on email.

On 01/22/2013 03:11:19 AM, Eric W. Biederman wrote:
> 
> The kernel support for user namespaces allows ordinary users to use
> multiple uids and gids if they can get a trusted program to tell the
> kernel the set of subordinate uids and gids they are allowed to use.

Could you give an example of this? (If this takes off I'll probably  
want to add support to toybox, but from the man pages I don't  
understand what it's for.)

> This is my work to make that trusted program.
> Two new files are added /etc/subuid /etc/subgid that specify
> ranges of uids and gids that users may uses.

They must use a contiguous range with count, not  
"landley:4000-4999,6103,7002-7005"?

> useradd, and newusers are modifed to add users to those files.
> userdel is modeifed to remove users from those files.
> usermod is modified to give manual control of what goes in those  
> files.

> newuidmap and newgidmap read the new files and update
> /proc/[pid]/uid_map and /proc/[pid]/gid_map respectively
> as requested by their command line parameters and as allowed
> by the /etc/subuid and /etc/subgid.

I'm not finding uid_map and gid_map in  
Documentation/filesystems/proc.txt, is this a pending patch?

Rob
