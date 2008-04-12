From: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Subject: Re: Multiple instances of devpts
Date: Sat, 12 Apr 2008 12:24:32 -0700
Message-ID: <48010C70.2030902@zytor.com>
References: <20080412172933.GA19295@us.ibm.com>	
	<20080412183514.GO9785@ZenIV.linux.org.uk>
	<48010583.3020403@zytor.com>
	<1208027757.28187.25.camel@x61.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1208027757.28187.25.camel-xJGG6ySDJhrj0SQisxZUdA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
>>
>> /dev/ptmx can be a symlink ptmx -> pts/ptmx, and we add a ptmx instance 
>> inside the devpts filesystem.  Each devpts filesystem is responsible for 
>> its own pool of ptys, with own numbering, etc.
>>
>> This does mean that entries in /dev/pts are more than just plain device 
>> nodes, which they are now (you can cp -a a device node from /dev/pts 
>> into another filesystem and it will still "just work"), but I doubt this 
>> actually matters to anyone.  If anyone cares, now I guess would be a 
>> good time to speak up.
> 
> Agreed.   That is another legitimate path.  And if all you care about is
> isolation and not dealing with the general class of problems with the
> global device number to device mapping that is sane.  I know we have
> several other virtual devices that we tend to care about but ptys are
> the real world pain point.
> 

Thinking about it further, allowing this restriction would also allow a 
whole lot of cleanups inside the pty setup, since it would eliminate the 
need to do a separate lookup to find the corresponding devpts entry in 
pty_open().  The benefit here comes from the closer coupling between the 
pty and the devpts filesystem and isn't at all related to namespaces, 
but it's a very nice side benefit.

	-hpa
