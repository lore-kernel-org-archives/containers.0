From: Krister Johansen <kjlx-6woCzk5+qv5TrMCiz+cRkdBPR1lH4CV8@public.gmane.org>
Subject: Re: Possible bug: detached mounts difficult to cleanup
Date: Fri, 13 Jan 2017 15:28:26 -0800
Message-ID: <20170113232826.GB3094@templeofstupid.com>
References: <20170111012454.GB2497@templeofstupid.com>
	<87fukqwcue.fsf@xmission.com> <87shoqtj7z.fsf@xmission.com>
	<20170112061539.GA2345@templeofstupid.com>
	<87r348y98z.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87r348y98z.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jan 12, 2017 at 09:26:20PM +1300, Eric W. Biederman wrote:
> At which point you have an island of mounts.
> 
> In that island each submount is on it's parent's mnt_pin list.
> When the last reference of a parent is dropped we call
>     umount_mnt on the children from mntput_no_expire
>     drop_mountpoint from mnt_pin_kill from cleanup_mnt indirectly from mntput_no_expire
> 
> So all we need is mntput_no_expire on a mount to be called for the
> entire island to be freed.
> 
> So the fundamental issue appears to be that nothing is dropping the last
> reference to some part of your island of mounts.

Ok, got it.  With the pointer from Andrei I was able to go back and
verify that the container's init process had live memory mappings from
files that were on the old root.  I apologize for the false alarm, and I
do appreciate you taking the time to explain the particulars.

-K
