From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 00/30] C/R OpenVZ/Virtuozzo style
Date: Tue, 14 Apr 2009 10:09:27 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904141006170.18124__32423.3668776744$1239729529$gmane$org@localhost.localdomain>
References: <20090410023207.GA27788@x200.localdomain>
	<alpine.LFD.2.00.0904100758410.4583@localhost.localdomain>
	<20090413073925.GB7085@x200.localdomain>
	<alpine.LFD.2.00.0904131137520.26713@localhost.localdomain>
	<20090414122906.GA20201@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090414122906.GA20201-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org



On Tue, 14 Apr 2009, Alexey Dobriyan wrote:
> > 
> > We're not merging OpenVZ code _either_.
> 
> This is to give example of other prefixes: cpt_ and rst_
> Are they fine?

Do you secretly work for IBM?

IBM has a well-known disdain for vowels, and basically refuses to use them 
for mnemonics (they were called on this, and did "eieio" as an instruction 
just to try to make up for it).

But I'm from Finland. In Finnish, about 75% of all letters are vowels. I 
find this dis-emvoweling to be stupid and impractical. Without vowels, you 
can't tell Finnish words apart (admittedly, _with_ vowels, you generally 
cannot pronounce them, so to a non-Finn it doesn't much matter).

My point is, let's go for a happy medium - LEAVE THE F*CKING VOWELS IN 
PLACE ALREADY.

So let's call it "checkpoint" and "restore". Ok?

		Linus
