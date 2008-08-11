From: Jeremy Fitzhardinge <jeremy-TSDbQ3PG+2Y@public.gmane.org>
Subject: Re: checkpoint/restart ABI
Date: Mon, 11 Aug 2008 16:38:46 -0700
Message-ID: <48A0CD86.6030704__45280.8096576065$1218498070$gmane$org@goop.org>
References: <20080807224033.FFB3A2C1@kernel>	
	<200808090013.41999.arnd@arndb.de>
	<20080811152201.GB25930@us.ibm.com>	
	<200808111853.13854.arnd@arndb.de>
	<1218484114.5598.43.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1218484114.5598.43.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Peter Chubb <peterc-M3ycANVxPotyL3EAZA59ERCuuivNXqWP@public.gmane.org>
List-Id: containers.vger.kernel.org

Dave Hansen wrote:
> Arnd, Jeremy and Oren,
>
> Thanks for all of the very interesting comments about the ABI.  
> Considering that we're still *really* early in getting this concept
> merged up into mainline, what do you all think we should do now?
>
> My main goal here is just to get everyone to understand the approach
> that we're proposing rather than to really fix the interfaces in stone.
> I bet we're going to be changing them a lot before these patches
> actually get in.
>   
Yes.

It seems to me that worrying about ABI at this point is a bit premature.

This feature, as it currently stands, is essentially useless for any 
practical purpose.  Self-checkpointing a single process with no handling 
of non-file file descriptors and no proper handling of file 
file-descriptors is not very useful.

My understanding that this is basically a prototype for a more useful 
multi-process or container-wide checkpoint facility.

While you could try to come up with an extensible file format that would 
be able to handle any future extensions, the chances are you'd get it 
wrong and need to break file format compatibility anyway.

I'm more interested in seeing a description of how you're doing to 
handle things like:

    * multiple processes
    * pipes
    * UNIX domain sockets
    * INET sockets (both inter and intra machine)
    * unlinked open files
    * checkpointing file content
    * closed files (ie, files which aren't currently open, but will be
      soon, esp tmp files)
    * shared memory
    * (Peter, what have I forgotten?)

Having gone through this before, I don't think an all-kernel solution 
can work except for the most simple cases.

Which, come to think of it, is an important point.  What are the 
expected use-cases for this feature?  Do you really mean 
checkpoint/restart?  Do you expect to be able to checkpoint a process, 
leave it running, then "rewind" by restoring the image?  Or does 
checkpoint always atomically kill the source process(es)?  Are you 
expecting to be able to resume on another machine?

Lightweight filesystem checkpointing, such as btrfs provides, would seem 
like a powerful mechanism for handling a lot of the filesystem state 
problems.  It would have been useful when we did this...

    J
