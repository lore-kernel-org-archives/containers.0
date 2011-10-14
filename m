From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Detecting if you are running in a container
Date: Fri, 14 Oct 2011 11:04:55 -0700
Message-ID: <m17h478n5k.fsf@fess.ebiederm.org>
References: <20111011013201.GA7948@thunk.org>
	<20111011020530.GG16723@count0.beaverton.ibm.com>
	<20111011032523.GB7948@thunk.org> <m1ty7ghvvn.fsf@fess.ebiederm.org>
	<203BBB0D-293D-4BFB-A57B-41C56F58F9B3@mit.edu>
	<m17h4bfcuv.fsf@fess.ebiederm.org>
	<20111012175702.GA23231@fieldses.org>
	<CAGZ=bqJxadNqaPCW3HufrMmQ57x082=pCDa6-mWLsdtfxHgdPw@mail.gmail.com>
	<20111012190452.GA23845@fieldses.org>
	<CAGZ=bqJjgmtBfyXJ2eK1C0PfzkgBVWFTjkTYkC211ZT+-5f-UQ@mail.gmail.com>
	<20111014155406.GC13119@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111014155406.GC13119@thunk.org> (Ted Ts'o's message of "Fri,
	14 Oct 2011 11:54:06 -0400")
Sender: linux-kernel-owner@vger.kernel.org
To: Ted Ts'o <tytso@mit.edu>
Cc: Kyle Moffett <kyle@moffetthome.net>, "J. Bruce Fields" <bfields@fieldses.org>, Matt Helsley <matthltc@us.ibm.com>, Lennart Poettering <mzxreary@0pointer.de>, Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, harald@redhat.com, david@fubar.dk, greg@kroah.com, Linux Containers <containers@lists.osdl.org>, Linux Containers <lxc-devel@lists.sourceforge.net>, "Serge E. Hallyn" <serge@hallyn.com>, Daniel Lezcano <daniel.lezcano@free.fr>, Paul Menage <paul@paulmenage.org>
List-Id: containers.vger.kernel.org

Ted Ts'o <tytso@mit.edu> writes:

>> I am of course making it sound a million times easier than it's
>> actually likely to be, but I do think it's possible without too many
>> odd corner cases.
>
> It's not the corner cases, it's all of the different name spaces that
> different system administrators and their sites are going to want to
> use, and how to support them all....
>
> And of course, once we start naming uid name spaces, eventually
> someone will want to virtualize containers, and then we will have
> namespaces for namespaces.  (It's turtles all the way down!  :-)

I have found and merged a solution that allows us to name namespaces
without needing a namespaces for namespaces.

Eric
