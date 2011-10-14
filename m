From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: Detecting if you are running in a container
Date: Fri, 14 Oct 2011 14:58:32 -0700
Message-ID: <4E98B088.5030400@zytor.com>
References: <20111011013201.GA7948@thunk.org> <20111011020530.GG16723@count0.beaverton.ibm.com> <20111011032523.GB7948@thunk.org> <m1ty7ghvvn.fsf@fess.ebiederm.org> <203BBB0D-293D-4BFB-A57B-41C56F58F9B3@mit.edu> <m17h4bfcuv.fsf@fess.ebiederm.org> <20111012175702.GA23231@fieldses.org> <CAGZ=bqJxadNqaPCW3HufrMmQ57x082=pCDa6-mWLsdtfxHgdPw@mail.gmail.com> <20111012190452.GA23845@fieldses.org> <CAGZ=bqJjgmtBfyXJ2eK1C0PfzkgBVWFTjkTYkC211ZT+-5f-UQ@mail.gmail.com> <20111014155406.GC13119@thunk.org> <m17h478n5k.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m17h478n5k.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Ted Ts'o <tytso@mit.edu>, Kyle Moffett <kyle@moffetthome.net>, "J. Bruce Fields" <bfields@fieldses.org>, Matt Helsley <matthltc@us.ibm.com>, Lennart Poettering <mzxreary@0pointer.de>, Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, harald@redhat.com, david@fubar.dk, greg@kroah.com, Linux Containers <containers@lists.osdl.org>, Linux Containers <lxc-devel@lists.sourceforge.net>, "Serge E. Hallyn" <serge@hallyn.com>, Daniel Lezcano <daniel.lezcano@free.fr>, Paul Menage <paul@paulmenage.org>
List-Id: containers.vger.kernel.org

On 10/14/2011 11:04 AM, Eric W. Biederman wrote:
> 
> I have found and merged a solution that allows us to name namespaces
> without needing a namespaces for namespaces.
> 

Something based on UUIDs, perhaps?

UUIDs are kind of exactly this, after all... a single namespace designed
to be large and random enough to be globally unique without a central
registration authority.

	-hpa
