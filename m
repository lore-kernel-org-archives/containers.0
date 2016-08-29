From: kbuild test robot <lkp-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 1/3] Make call_usermodehelper_exec possible to set pid
	namespace
Date: Tue, 30 Aug 2016 00:58:20 +0800
Message-ID: <201608300022.kW2H6bFr%fengguang.wu@intel.com>
References: <94bf69d92a3204491862b8c72111f4e046bf5f9e.1472471586.git.zhaolei@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MGYHOYXEY6WxJCY8"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <94bf69d92a3204491862b8c72111f4e046bf5f9e.1472471586.git.zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, kbuild-all-JC7UmRfGjtg@public.gmane.org
List-Id: containers.vger.kernel.org


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Zhao,

[auto build test WARNING on linus/master]
[also build test WARNING on v4.8-rc4 next-20160825]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
[Suggest to use git(>=2.9.0) format-patch --base=<commit> (or --base=auto for convenience) to record what (public, well-known) commit your patch series was built on]
[Check https://git-scm.com/docs/git-format-patch for more information]

url:    https://github.com/0day-ci/linux/commits/Zhao-Lei/Make-core_pattern-support-namespace/20160829-201413
reproduce: make htmldocs

All warnings (new ones prefixed by >>):

   lib/crc32.c:148: warning: No description found for parameter 'tab)[256]'
   lib/crc32.c:148: warning: Excess function parameter 'tab' description in 'crc32_le_generic'
   lib/crc32.c:293: warning: No description found for parameter 'tab)[256]'
   lib/crc32.c:293: warning: Excess function parameter 'tab' description in 'crc32_be_generic'
   lib/crc32.c:1: warning: no structured comments found
>> kernel/kmod.c:624: warning: No description found for parameter 'init_intermediate'

vim +/init_intermediate +624 kernel/kmod.c

a06a4dc3 Neil Horman         2010-05-26  608   *
a06a4dc3 Neil Horman         2010-05-26  609   * The init function is used to customize the helper process prior to
a06a4dc3 Neil Horman         2010-05-26  610   * exec.  A non-zero return code causes the process to error out, exit,
a06a4dc3 Neil Horman         2010-05-26  611   * and return the failure to the calling process
0ab4dc92 Jeremy Fitzhardinge 2007-07-17  612   *
a06a4dc3 Neil Horman         2010-05-26  613   * The cleanup function is just before ethe subprocess_info is about to
0ab4dc92 Jeremy Fitzhardinge 2007-07-17  614   * be freed.  This can be used for freeing the argv and envp.  The
0ab4dc92 Jeremy Fitzhardinge 2007-07-17  615   * Function must be runnable in either a process context or the
0ab4dc92 Jeremy Fitzhardinge 2007-07-17  616   * context in which call_usermodehelper_exec is called.
0ab4dc92 Jeremy Fitzhardinge 2007-07-17  617   */
938e4b22 Lucas De Marchi     2013-04-30  618  struct subprocess_info *call_usermodehelper_setup(char *path, char **argv,
938e4b22 Lucas De Marchi     2013-04-30  619  		char **envp, gfp_t gfp_mask,
a0807e8e Zhao Lei            2016-08-29  620  		int (*init_intermediate)(struct subprocess_info *info),
87966996 David Howells       2011-06-17  621  		int (*init)(struct subprocess_info *info, struct cred *new),
a06a4dc3 Neil Horman         2010-05-26  622  		void (*cleanup)(struct subprocess_info *info),
a06a4dc3 Neil Horman         2010-05-26  623  		void *data)
0ab4dc92 Jeremy Fitzhardinge 2007-07-17 @624  {
938e4b22 Lucas De Marchi     2013-04-30  625  	struct subprocess_info *sub_info;
938e4b22 Lucas De Marchi     2013-04-30  626  	sub_info = kzalloc(sizeof(struct subprocess_info), gfp_mask);
938e4b22 Lucas De Marchi     2013-04-30  627  	if (!sub_info)
938e4b22 Lucas De Marchi     2013-04-30  628  		goto out;
938e4b22 Lucas De Marchi     2013-04-30  629  
b6b50a81 Frederic Weisbecker 2015-09-09  630  	INIT_WORK(&sub_info->work, call_usermodehelper_exec_work);
938e4b22 Lucas De Marchi     2013-04-30  631  	sub_info->path = path;
938e4b22 Lucas De Marchi     2013-04-30  632  	sub_info->argv = argv;

:::::: The code at line 624 was first introduced by commit
:::::: 0ab4dc92278a0f3816e486d6350c6652a72e06c8 usermodehelper: split setup from execution

:::::: TO: Jeremy Fitzhardinge <jeremy-8XJ3FbD+ij9l57MIdRCFDg@public.gmane.org>
:::::: CC: Jeremy Fitzhardinge <jeremy-TSDbQ3PG+2Y@public.gmane.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--MGYHOYXEY6WxJCY8
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

H4sICCxUxFcAAy5jb25maWcAjFxZc+O2sn7Pr2Al9yGpupnF9vg4dcsPEAiKiLgNAUqyX1ga
mTOjii35aElm/v3tBkhxa2hyqlJnjG6AWHr5utHQLz/94rHTcfeyOm7Wq+fn796XalvtV8fq
yfu8ea7+z/NTL0m1J3yp3wBztNmevr3dXN/dejdv7t68+32/vvFm1X5bPXt8t/28+XKC3pvd
9qdfgJunSSCn5e3NRGpvc/C2u6N3qI4/1e3Lu9vy+ur+e+fv9g+ZKJ0XXMs0KX3BU1/kLTEt
dFboMkjzmOn7n6vnz9dXv+Osfm44WM5D6BfYP+9/Xu3XX99+u7t9uzazPJg1lE/VZ/v3uV+U
8pkvslIVWZbmuv2k0ozPdM64GNPiuGj/MF+OY5aVeeKXsHJVxjK5v7tEZ8v797c0A0/jjOkf
jtNj6w2XCOGXalr6MSsjkUx12M51KhKRS15KxZA+JoQLIaehHq6OPZQhm4sy42Xg85aaL5SI
yyUPp8z3SxZN01zqMB6Py1kkJznTAs4oYg+D8UOmSp4VZQ60JUVjPBRlJBM4C/koWg4zKSV0
kZWZyM0YLBeddZnNaEginsBfgcyVLnlYJDMHX8amgmazM5ITkSfMSGqWKiUnkRiwqEJlAk7J
QV6wRJdhAV/JYjirEOZMcZjNY5Hh1NFk9A0jlapMMy1j2BYfdAj2SCZTF6cvJsXULI9FIPg9
TQTNLCP2+FBOlat7keXpRHTIgVyWguXRA/xdxqJz7vZLeeoz3TmNbKoZ7AaI5VxE6v6q5Q4a
dZQK9Pvt8+bT25fd0+m5Orz9nyJhsUDZEEyJt28GCizzj+UizTuHNClk5MOWiFIs7feU1V5j
o6bG4D2jXTq9QkvTKU9nIilhHSrOulZJ6lIkc9gJnFws9f31edo8h+M1mijhiH/+ubWAdVup
haIMIew9i+YiVyBCvX5dQskKnRKdjczPQAJFVE4fZTbQhpoyAcoVTYoeu5rfpSwfXT1SF+Gm
JfTndF5Td0Ld5QwZcFqX6MvHy73Ty+QbYitB7lgRgSqmSqOQ3f/863a3rX7rnIh6UHOZcXJs
e/4g92n+UDINDiMk+YKQJX4kSFqhBFhG1zEb/WMFOGOYB4hG1EgxSL13OH06fD8cq5dWis/2
HZTCKCth+oGkwnTRkXFoAc/KwYDoEKyn37MgKmO5EsjUtnH0miotoA9YKs1DPx3anC5L3wh0
KXNwCz56hYihsX3gETFjo8rzdgOGrgXHA4OSaHWRiN60ZP6fhdIEX5yifcO5NFusNy/V/kDt
cviIrkKmvuRdQU9SpEjXSRsySQnB5YJ9U2alueryWFiVFW/16vCXd4Qpeavtk3c4ro4Hb7Ve
707b42b7pZ2blnxm/SDnaZFoe5bnT+FZm/1syaPP5bzw1HjVwPtQAq07HPwJRhY2g7JyasCs
mZop7EJuAg4FmCuK0HjGaUIy6VwIw2mAmXMcnBLojCgnaapJLuMjAD0lV7Rqy5n9h0sxC0Cr
1rUAMvGtmHXXyqd5WmSKNhuh4LMsleDh4dB1mtMLsSOjEzBj0YtFMEUvMJqBeZsbB5b7xDI4
PwMH1H6UaAOvEy56CxmwIf4iRmMJOCyZAGpXA09RSP99B+ajGusIToiLzCAoc5KDPhlX2Qym
FDGNc2qpVta684vBfkswojm9hwCcYhC7srYeNNODCtRFjhkQ1ENMH2eWw0nOHFI2pbv010f3
BbBTBoVjRkGhxZKkiCx1rVNOExYFPq1ZaHocNGM/HbRJFlze3BD8I0lhkvbYzJ9LWHo9KL3n
eODGdTtmBd+csDyXfbFoloNhgC/8odDBkOXZjxhLWAe6WbX/vNu/rLbryhN/V1swvQyMMEfj
Cy6iNZH9Ic6zqWE3EmHi5Tw26Juc+Dy2/UtjnQfOoAcvMfjLabFTEaMQhYqKSXdaKkonzv5l
AKYW0XiZA3hJ6SOEM9IQ/6F/LwG1ykByExY59CQNZDRwON0DSC1Hxxg0LWUSSyuh3fn/WcQZ
AIeJoCWvjlZoj4vfM2kKCFpBLdDQci6Ucs1NBLA2iQcD0UivxwD34AGjcwFvWU7Ugg3huQRz
jzE8TE4PSLNheGVbc6FJAphluoNtxVAmoIwr7OWgxUzcsIZpOhsQMY0Af2s5LdKCQFgQLhnM
U2NHIo6FuPMB0DUiOWOKTZpn8JVcTBU4Ed+mXeqtLVk2nCrOBlqtSg1o4QI0QjDrWge0WC7h
xFqyMl8cuiqwKtCuizwBtKZBnLs5qKGRIDbSUImBG9XP6+X5RTyUC7NbrUSPkiD24ErFAgFg
NcOUy3CEWizt/poof8BR97NRpoPmp4UjXwFRUGljgSZyJVagBEfjVILW6tHmTQFMZFExlUnP
PHaaXeoHHGbnUGsEB8g0gCh9Io12+jxwwMkQ6Aw44CCLiNHAYswN2566bZvdRqlDMAtWBoIc
As6hoBDw3KGrCcZlok4j9c86Tv0iAgOApkhEKJBjcVKWYkz7OKM2TlkOGMQSLCep8P1ed/1T
TLOHulepo54MtJ+FudFRNOYsJ4UxCtQBR3CeAJr4bMFyvzPfFHA+IJ86I3c9IjCTcu5JAkRP
EKy1Jj8IxjHZlKfz3z+tDtWT95dFCa/73efNcy8YO282cpeNM+tFsVYxaltqbW0o8GA7+SxE
ggpBw/37DsSxp0xsRXP+JliKwKIXvXzMBGMVoptJHsKHMhDRIkGmftBf083pWfolGtl3kWNQ
5ujcJfZ797OQTKfoS/J4MeBAef9YiAJtICzCpBncLPmiYWhBNWzYYx8ymrPO9rt1dTjs9t7x
+6sNwD9Xq+NpXx261x6PKIG+I4kFbpJsx8xrIBj4HDDwaBHcXJgiaVgxsUizTkGuA+nQIRxH
LDUoAqa7L4UfdUZY5pL+jI1O4SS0tWSlcauOMCx8AA8IqB7M5LSgU6KgcBis2yRyK+Q3d7c0
wP9wgaAVDa6RFsdLSmVuzVVUywm2AsLKWEp6oDP5Mp3e2oZ6Q1NnjoXN/uNov6PbeV6olE4t
xMa2CQdQjxcy4SG4e8dEavK1K/SKmGPcqUh9MV2+v0AtIzqqjflDLpfO/Z5Lxq9LOr1siI69
44DGHb3QzDg1ozbYjjtOowiYC6kvrlQoA33/ocsSvR/QesNn4CpA1RNOpVqQAe2YYTK5JFV0
UiRIBgXoN9To7vZm2JzO+y2xTGRcxMYHBoDZo4f+vA3u5jqKVQ+CwVQQsCMMEhHgIcpBw4hg
w83mdPxf02zOt3c73FBY7BPsoEKsyMcEA41iAQEpNVYRc9vemqZMaBtakoftxxTYSMw9oQJ3
fF6/EHGmR6CyaZ+nEaA5ltO5uprLKW24CZmkbZo5tL6cWJ/VyVm87Lab425voUn71U4oA3sM
Bnzh2AQjsAKQ0kM5jx1210nQKYj4hHaK8o5OYOAHc4H+IJBLVxoVQABIHWiZe1+Uez1wfpI2
YEmK+fhB1qqRFku56eXU68bbGwr9z2OVReAkr3td2lYM4x0balmu6BRiS/7hCO+peZk77hSQ
rdD3777xd/Z/g3UO0FMAgAFaS5Ew4srbxIZusrELzWUZQNSuEZARilfUYAi8FirE/Xk2F/s2
k4pZUpiotoUo5xlZGrELdef+aKUx3bZfJ0xvh4MATsuOhbUZBhFP+ri211wP2h3QlqxIxSFg
6XbvB0U1KgK7GaRmECqzZ8450+ZDxjLdDJKF3J2WCx9A/30/L7WzcGcuczCSKYZfvZtdRelI
c6lqIkF75+bn9zfv/rjt3uOMA1jKznarMmY9ZMgjwRLjQun43AHDH7M0pdOFj5OCtgePapyv
bbB2HbeZGogmtecuvghEnvcTNOZ6ZmhLMu02acbfQ2ydYt1BnhfZ8Fx7FlQB6sYQcHF/2xGI
WOe0XTTzvZDuxUFhM9yBjPHtgG9pDFfnhugI4bF8/+4dZXEfy6sP73pb9Fhe91kHo9DD3MMw
w/AlzPG6lL7yEUvhuvVnKjQpPMqsgjZJDqYMbESOlvV9bVi7V3YpZ+by8FJ/k82D/leD7nXq
f+4r+vaEx76JpicuOQfzKYOHMvI1dW/TlQRrxxuzG6Yak3TN1Ui2+6fae4AvVl+ql2p7NFEx
45n0dq9YD9iLjOvkC21/HFcLQQ94NffgXrCv/nuqtuvv3mG9eh5AGoNac/GR7Cmfnqshs/Oy
3mwAmh915sMrmSwS/mjwyenQLNr7NePSq47rN7/1oBan45Y6pUUlY2yBXp0B73ZwROMoKCQp
jRzVKyBhtJ4mQn/48I6O0jKO3sptHR5UMBltkPhWrU/H1afnyhSZegaYHg/eW0+8nJ5XI3GZ
gK+LNWYo6StHS1Y8lxnlrWwuMS16hrXuhM2XBo2lI3eAkaJD5+33bFZKptYDdDdztB9+9fcG
YLm/3/xtrw/bwrTNum720rEaFfZqMBRR5gpXxFzHWeBI2Wgw7QzzpK4oxAwfyDxegGu2NRIk
a7AAp8J8xyTQWy5M8QG1aZ254q2on8u5czGGQcxzR1YMpK2TWqKzYU19DygxjCQ5mTHtcmHB
RVM61QkDmS3T9GFXgoDIEaIReDLn2juyWNM7mAbENGwCHetvz9W2gJHq0uP2nGzTaAbx5rCm
pgAHED9gQpWciEh4lCpMKSJYGO5Pu9U5o+00vyInIwTsYewdTq+vu/2xOx1LKf+45svbUTdd
fVsdPLk9HPenF3PRfvi62ldP3nG/2h5wKA9sfuU9wVo3r/jPRnvY87Har7wgmzIwMvuXf6Cb
97T7Z/u8Wz15tpa04ZXbY/XsgbqaU7P61tAUlwHRPE8zorUdKNwdjk4iX+2fqM84+Xev54yz
Oq6OlRe3fvZXnqr4t6HxwPmdh2v3mocOlLCMzLWCk8iColZNCC+d13LSP1fLKa5kLX2dUz+7
JyURePSiM2xzZctjxgFLpoizzCTG9y9y+3o6jj/YesokK8ZiGcJJGMmQb1MPu/RhChb1/Tu9
NKy9S0wWC1ITOAjwag3CSemm1nRGCEyVq2wGSDMXTWaxLG2xqSMRv7iE75O5S8szfvef69tv
5TRzFO0kiruJMKOpDVzciTbN4T8HFoSggg8vrawQXHHy7B1FfSqjYZjKYpoQqjEIzUAdiG9m
2VhGsa1+X7MzlaRNL0vVmbd+3q3/GhLE1kAlCAWwMhhxNYAILHHH6MBsIXjyOMNKmuMOvlZ5
x6+Vt3p62iBiWD3bUQ9vutPDsxnUGZ9pCwfUw3ygCV8jR9rSMGCUSUMqS2dzRwnOwlnkGYo8
ZnT00lQbU0kQNem+t7BWabfdrA+e2jxv1rutN1mt/3p9Xm17cQD0I0abcHD5w+Eme3Am692L
d3it1pvPANZYPGE96DpIPFjPfHo+bj6ftms8n8ZmPZ0NeGv1At9AJtokIjGHuN8RloYa0QIE
j9fO7jMRZw5Eh+RY317/4bgoAbKKXUEBmyw/vHt3eeoYa7rum4CsZcni6+sPS7y7YL7j/g4Z
Y4eRsdUa2oEDY+FL1uRiRgc03a9ev6KgEIrt9y9ILdjgmfcrOz1tduCrz7fDv41exBnmYL96
qbxPp8+fwQf4Yx8Q0FqJpQyR8TkR96mZt3neKcOMpKOKOC0Sqvy3AG1JQy7LSGoNwS2E55J1
SnqQPnr3ho3nmoaQ9/x5ocaBH7YZ0PbURyvYnn39fsA3iF60+o7OcawO+DWweI4kfWboSy7k
nORA6pT5U4dxKhb0tsexQ/ZErJzJokRAQCR82tDZWjY5kbDTD8RJCJ/xJnyEmLbovPMypPYU
WlwH7cRIOZgAMPJtf2yI+fub27v3dzWl1ReNryOYoicNwIwIl2z0GjOIgcg0z0PCsfLLkVIp
lr5UmatgvXDotck9u1DgfLOHWVDCg91kCsfZH7aOlNb73WH3+eiF31+r/e9z78upAvxOaD8o
1nRQstpLeDQ1FFRw2QLqECIeceYdL+MMS9XrZmsgwUBhuGlUu9O+5zma8aOZynkp764+dOqb
oFXMNdE6ifxza3s6OhZRmUlaWwCIG+hW8vgHDLEu6Av1M4eO6QcgIq4ZQM8cQYGMJimds5Jp
HBdO+55XL7tjhUEVJSpKC3OpFJc53mOPe7++HL4MT0QB46/KPJHx0i2g/M3rby0sGERnZ9yg
dpycQZEspTvGhm+Vjj3JjOQNc57tni610+uatC69mQ5VzBbUfQ8D6Z+C7YrZskzybomazLDQ
cZDg7DhsAI6mtDhPI1fAEsTj80Cf0H2fNEr2uJwGwudsycqruyRGbE9b+h4XeBFanAHolbM0
YYbD/UWEwNxxYxLzscckru0ps5SzsRFh26f9bvPUZYNQL09d19zOCFNpR3Rpbnd0OPqySbr0
sA+cz2jOhmvUtUnV+GOtEL4j+9gkKGEBrtsoX0RRmU9oS+Nzf8Jc1XPpNBLnTxDzhcjMSl7H
APu2lgditM6rgHa+CgMJuQQSHdSIJVotYLM3xamj4MEUjyKHyyEFylStO1IKF2jS0krnO6qA
Xej9sUg1ncYxFK7pVWOiNVA3pSNbHWCNk4OWAhgAHFESdbl8tf46wNdqdE1sVe1QnZ525kai
PdBWc8ETuD5vaDyUkZ8L2rjiq2NXFh5fm9ERnH3mf5laDq/KW5Rh/g+kyDEAXm0YGbKvdmim
JBpvaf0K6isEz/2npubHMWT+MYjYVHVwqun1ut9sj3+Z9MXTSwUOtAWMZw+kFN6BR6hyczAt
deXA/U19lLuXVzic382rVzjV9V8HM9zatu8pCGrvDLBWgtY0e6UJqo0/MpLlgkPc5Hj0Vt9+
FuZXIARZMm0rX3G0+/fvrm66JjSXWclUXDqfDWKttPkCU7S5LRLQAAyc40nqeAZni3gWycUL
lIBM3wq8vlF2ZeO3akrYH2IBmYkx40JL8oDJbmuaRFSU074j6ZULD+qvf1RIXK8oNQ/PBZs1
xSEOvIiwBKS9f/XRG8r+PEAjszHgxP13CNI/nb58GZbL4V6b2mnlKqUZ/LyG+8hgiSpNXGbc
DpNO/oT9dabe6+mDC4xgH8Yn2FAufMG+QymUy6BYrrkrDW2IEGUVjlSd5airB7DO5QLXhYq7
drFmvmj6g8j8fAG1nIbsGsmIIe7NSPDPjZd2LBxco9XXuSAuXgQR2unVWqhwtf3SM0votYsM
Rhk/UOp8Aolg5xP7VJ7Of34kU6Ad8UpA5kEpU/rapkcf1tlZIgZheHk+qpZxWlVLtuKEv3rz
o23EL8yEyKgfH8BtbBXQ+/VQR8SH//VeTsfqWwX/wPqKN/0Ki/p86mcfl+QRH0474nTLsVhY
Jnwfu8iYpo2f5TV47YKy5+n8MmQzA2D27sJHmtxQBFv2g7nAZ8zzSCWiwP1ExHwUxPD8ksQR
BjQ/gHXhozNrpi5NSzrGr62l/BGHumQlm2ealw6U58LHFxeMwDb4axS0uTdH5/qxivpHUfC3
Ji65qx/usRkA67AvcvyrYX7wixgf619/uiT49c/AlLnbpzb7XYo8T3MwCX8Kd2mprQMlebqo
AJPJjQmH8F3bl7LmsaB93kDZepKR+EL76tbxW27GLQRFwttfoxi+Wz1TpznLwn/FE2TmtIav
l+t30OS77D7RPBal3hLX5Ni8DwUGDkHngOX/+7iaHjdhIPpX+hOSpqp6BQNbdylBYKKwF9RW
OeypUrp72H/f+SA2NjM+Js8kNrZnxuN5b63r444y3Tll+64P8q8EEJ9AGyLknJvdAuMNhAI0
EJ+727+3ZAvhC6DNTfpbchYlzAvyUfUFXhKZUcXZRH794g2fvB2xQ9/rq1qSRA1wbXVPa5WV
bFeo3TM0dEo6khqQMIhcwkZ4aZ2WviB80hgKhA5IlN2VkSZjTbi0j7dO4jfV2YxDJGAUkesz
/apU1RmIoXR/UvzsZcLqJjJ7qqJLCvycMxtTORYd/DJElyhQw8zacIJCNG91LlRaP3LNWh0X
qLCNyZRi4AUAxJvleeQyfUWkh6vDMzIxdJHgcFXqd6ihTcaCs96evk1WOy+vWWb+k83OxW5t
2bSTRtHmLDzsVV1JA29kFFNsz6wOubi5r5fD9dshxKYpBnN1lDFenkFcMEaJoXXaYfRn20Lb
ACj5Ad8isx18my4puvSvdHWR2y5uA2/TF5nd6IWZHrqPmXmDAEjJ9ntaHzgt2en3E6ogoo3d
d4YvQ25/3u+vbx9SRua5npVEWG2mwboZzE490nUAbbhsWzmXQeIfxQBBHhxD0OFTSEBhecFa
ETtDs2se824SMDN1YRTFhhGUorE45DD3GWXHS8RzWU/Y9kUX1iltVwyz4G74QPX6+/7r/vHp
/vcdHPRtk3/zCi5u6Ay8sAbrMnHIgsgLNGnrTkEb2z1kVUsriOv1xvrC6ARSvxYUK4gAT3pf
fWtjKSAzmMUY6+TVA+hRJific+54qKzsphG2DmJrDT3Jl0OAyHU0rS3pKY1ZYmQuNylArrqK
zP8QCMghWKIKv9PnfDB0fUGZ5Qy0lOaHuEhHnLUtaY6/QlseE9zIxW61Rv1U+ngN/8c2dD/i
7CUWZIH4VBlhVcnnLZK9VOXPVp6cBqbMsLTPI17kF7YThoM+bSG3COB/HvxyGGRbAAA=

--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--MGYHOYXEY6WxJCY8--
