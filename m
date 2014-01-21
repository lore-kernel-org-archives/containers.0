From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Pass a fd to program in another mount namespace?
Date: Tue, 21 Jan 2014 17:07:08 -0600
Message-ID: <20140121230708.GA2342@ac100>
References: <1390314790.19789.79.camel@pentium.freedom.box>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1390314790.19789.79.camel-fUTaybRSAecurNyw8EiOWGKXln2oN1SQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Rob van der Hoeven <robvanderhoeven-nv30jWqA7Mk@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Rob van der Hoeven (robvanderhoeven-nv30jWqA7Mk@public.gmane.org):
> Hi,
> 
> I was wondering if it is possible to send a file descriptor to a program
> running in another mount namespace. Sendmsg/recvmsg can pass fd's in the
> ancillary data and this works great until my program switches to another
> mount namespace using:
> 
> unshare(CLONE_NEWNS)
> pivot_root(".", "./us_rootfs")
> 
> If there is a way to pass descriptors across mount namespaces then it
> would greatly benefit my program so I hope this is possible. 

Yes, it is possible.  Your email makes it sound like you've tried
and it didn't work for you, in which case a short test case showing
what fails might be useful here.

-serge
