From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [patch 9/9] unprivileged mounts: add "no submounts" flag
Date: Tue, 15 Jan 2008 07:47:19 -0600
Message-ID: <20080115134719.GB4453@sergelap.austin.ibm.com>
References: <20080108113502.184459371@szeredi.hu> <20080108113634.382855604@szeredi.hu> <20080114233910.GI6704@sergelap.austin.ibm.com> <E1JEjEE-0000xZ-RU@pomaz-ex.szeredi.hu> <643ea2b10801150253i735d7342q73bf01f864d6167c@mail.gmail.com> <E1JEjUx-00010q-Ny@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <E1JEjUx-00010q-Ny@pomaz-ex.szeredi.hu>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: accensi@gmail.com, serue@us.ibm.com, akpm@linux-foundation.org, hch@infradead.org, viro@ftp.linux.org.uk, ebiederm@xmission.com, kzak@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org, util-linux-ng@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Miklos Szeredi (miklos@szeredi.hu):
> > Why not "nosubmnt"?
> 
> Why not indeed.  Maybe I should try to use my brain sometime.

Well it really should have 'user' or 'unpriv' in the name
somewhere.  'nosubmnt' is more confusing than 'nomnt' because
it no submounts really sounds like a reasonable thing in
itself...

But I never win naming arguments, so I accept that I have poor
naming judgement  :)

-serge
