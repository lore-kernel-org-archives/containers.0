From: "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: 3.9-rc1 NULL pointer crash at find_pid_ns
Date: Thu, 14 Mar 2013 14:00:38 -0700
Message-ID: <20130314210038.GD3725@linux.vnet.ibm.com>
References: <876213wmwt.fsf@xmission.com> <5138D001.8000409@oracle.com>
	<1362678371.15793.218.camel@edumazet-glaptop>
	<5138D377.6040406@oracle.com> <87boavrspd.fsf@xmission.com>
	<5138D8F2.5020900@oracle.com>
	<20130307182934.GY3268@linux.vnet.ibm.com>
	<513AEC65.8000008@huawei.com>
	<20130309155146.GR3268@linux.vnet.ibm.com>
	<20130314200054.GA5924@redhat.com>
Reply-To: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130314200054.GA5924-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, CAI Qian <caiqian-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Mar 14, 2013 at 04:00:54PM -0400, Dave Jones wrote:
> On Sat, Mar 09, 2013 at 07:51:46AM -0800, Paul E. McKenney wrote:
>  > On Sat, Mar 09, 2013 at 04:01:41PM +0800, Li Zefan wrote:
>  > 
>  > [ . . . ]
>  > 
>  > > > This way, "ptr" is executed exactly once, and the check and the
>  > > > hlist_entry() are both using the same value.
>  > > 
>  > > I just played with trinity, and triggered this bug in just a few mins,
>  > > and I tried Paul's proposed fix and it works.
>  > 
>  > Thank you for testing this!  Please see below for the patch.
>  > 
>  > Sasha, will you be pushing this or would you like me to do so?
> 
> [crickets]
> 
> Given this has been hanging for the better part of another week,
> Paul why not send it Linus so hopefully rc3 doesn't have this bug ?

Good point!  I sent a pull request.

							Thanx, Paul
